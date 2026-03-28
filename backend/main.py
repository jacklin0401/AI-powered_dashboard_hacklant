from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv
import yfinance as yf
import requests
from anthropic import Anthropic
import json

# Load environment variables
load_dotenv()

app = FastAPI(title="PortfolioIQ Backend", version="1.0.0")

# Configure CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize APIs
anthropic = Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
ALPHA_VANTAGE_API_KEY = os.getenv("ALPHA_VANTAGE_API_KEY")

# Pydantic models
class Holding(BaseModel):
    ticker: str
    shares: float
    avgPrice: float
    value: Optional[float] = None
    sector: Optional[str] = None
    beta: Optional[float] = None
    pe: Optional[float] = None
    change: Optional[float] = None
    gain: Optional[float] = None

class PortfolioAnalysis(BaseModel):
    risk_score: float
    diversification_grade: str
    insights: List[str]
    recommendations: List[str]
    weaknesses: List[str]

class AnalyzeRequest(BaseModel):
    holdings: List[Holding]

# API endpoints
@app.get("/")
async def root():
    return {"message": "PortfolioIQ Backend API", "status": "running"}

@app.post("/api/analyze-portfolio", response_model=PortfolioAnalysis)
async def analyze_portfolio(request: AnalyzeRequest):
    """Analyze portfolio using Claude AI"""
    try:
        # Enrich holdings with market data
        enriched_holdings = []
        for holding in request.holdings:
            enriched = await enrich_holding(holding)
            enriched_holdings.append(enriched)

        # Generate analysis prompt
        analysis_prompt = generate_analysis_prompt(enriched_holdings)

        # Call Claude API
        message = anthropic.messages.create(
            model="claude-3-sonnet-20240229",
            max_tokens=2000,
            temperature=0.7,
            system="You are a financial analyst providing portfolio analysis. Be direct, practical, and focus on actionable insights.",
            messages=[
                {"role": "user", "content": analysis_prompt}
            ]
        )

        # Parse Claude response
        response_text = message.content[0].text
        analysis = parse_claude_response(response_text)

        return analysis

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")

async def enrich_holding(holding: Holding) -> Holding:
    """Enrich a holding with market data"""
    try:
        # Try yfinance first (more reliable)
        stock = yf.Ticker(holding.ticker)
        info = stock.info

        # Get current price
        current_price = info.get('currentPrice') or info.get('regularMarketPrice', holding.avgPrice)

        # Calculate gain
        gain = ((current_price - holding.avgPrice) / holding.avgPrice) * 100

        # Get sector and other metrics
        sector = info.get('sector', 'Unknown')
        beta = info.get('beta', 1.0)
        pe = info.get('trailingPE', 20.0)

        # Get daily change
        change = info.get('regularMarketChangePercent', 0.0)

        return Holding(
            ticker=holding.ticker,
            shares=holding.shares,
            avgPrice=holding.avgPrice,
            value=current_price * holding.shares,
            sector=sector,
            beta=beta,
            pe=pe,
            change=change,
            gain=gain
        )

    except Exception as e:
        print(f"Error enriching {holding.ticker}: {e}")
        # Return with basic data if enrichment fails
        return Holding(
            ticker=holding.ticker,
            shares=holding.shares,
            avgPrice=holding.avgPrice,
            value=holding.avgPrice * holding.shares,
            sector="Unknown",
            beta=1.0,
            pe=20.0,
            change=0.0,
            gain=0.0
        )

def generate_analysis_prompt(holdings: List[Holding]) -> str:
    """Generate analysis prompt for Claude"""
    total_value = sum(h.value for h in holdings if h.value)

    portfolio_summary = []
    for h in holdings:
        if h.value:
            allocation = (h.value / total_value) * 100
            portfolio_summary.append({
                "ticker": h.ticker,
                "sector": h.sector,
                "allocation": ".1f",
                "beta": h.beta,
                "pe": h.pe,
                "gain": ".1f"
            })

    prompt = f"""
Analyze this investment portfolio and provide insights. Return your response as a JSON object with these exact keys:
- risk_score: A number from 1-10 (1 being very low risk, 10 being very high risk)
- diversification_grade: One of "A", "B", "C", "D", "F"
- insights: Array of 3-5 key insights about the portfolio
- recommendations: Array of 3-5 actionable recommendations
- weaknesses: Array of 2-4 portfolio weaknesses

Portfolio Summary:
{json.dumps(portfolio_summary, indent=2)}

Total Portfolio Value: ${total_value:,.2f}

Focus on:
- Risk assessment based on sector allocation and individual stock betas
- Diversification quality across sectors and companies
- Performance analysis
- Potential red flags or concerns
- Specific, actionable recommendations

Be direct and practical in your analysis.
"""

    return prompt

def parse_claude_response(response_text: str) -> PortfolioAnalysis:
    """Parse Claude's JSON response"""
    try:
        # Try to extract JSON from the response
        start_idx = response_text.find('{')
        end_idx = response_text.rfind('}') + 1

        if start_idx != -1 and end_idx != -1:
            json_str = response_text[start_idx:end_idx]
            data = json.loads(json_str)

            return PortfolioAnalysis(
                risk_score=float(data.get('risk_score', 5.0)),
                diversification_grade=data.get('diversification_grade', 'C'),
                insights=data.get('insights', []),
                recommendations=data.get('recommendations', []),
                weaknesses=data.get('weaknesses', [])
            )
        else:
            # Fallback if JSON parsing fails
            return PortfolioAnalysis(
                risk_score=5.0,
                diversification_grade="C",
                insights=["Analysis completed"],
                recommendations=["Consider diversifying your portfolio"],
                weaknesses=["Unable to parse detailed analysis"]
            )

    except Exception as e:
        print(f"Error parsing Claude response: {e}")
        return PortfolioAnalysis(
            risk_score=5.0,
            diversification_grade="C",
            insights=["Analysis completed with limited detail"],
            recommendations=["Review your portfolio allocation"],
            weaknesses=["Analysis parsing error"]
        )

@app.get("/api/market-data/{ticker}")
async def get_market_data(ticker: str):
    """Get market data for a specific ticker"""
    try:
        stock = yf.Ticker(ticker)
        info = stock.info

        return {
            "ticker": ticker,
            "price": info.get('currentPrice') or info.get('regularMarketPrice'),
            "sector": info.get('sector'),
            "beta": info.get('beta'),
            "pe": info.get('trailingPE'),
            "market_cap": info.get('marketCap'),
            "fifty_two_week_high": info.get('fiftyTwoWeekHigh'),
            "fifty_two_week_low": info.get('fiftyTwoWeekLow'),
        }

    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Could not fetch data for {ticker}: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)