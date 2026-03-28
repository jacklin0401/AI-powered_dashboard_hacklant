from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv
import yfinance as yf
from anthropic import Anthropic
import json

load_dotenv()

app = FastAPI(title="PortfolioIQ Backend", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

anthropic_client = Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))


# ── Pydantic models ────────────────────────────────────────────────────────────

class HoldingInput(BaseModel):
    ticker: str
    shares: float
    avgPrice: float

class AnalyzeRequest(BaseModel):
    holdings: List[HoldingInput]

class PortfolioAnalysisResponse(BaseModel):
    risk_score: float
    diversification_grade: str
    insights: List[str]
    recommendations: List[str]
    weaknesses: List[str]


# ── Helper: fetch market data via yfinance ─────────────────────────────────────

def fetch_market_data(ticker: str) -> dict:
    try:
        stock = yf.Ticker(ticker)
        info = stock.info
        price = info.get('currentPrice') or info.get('regularMarketPrice') or 0.0
        return {
            "ticker": ticker,
            "price": float(price),
            "sector": info.get('sector') or 'Unknown',
            "beta": float(info.get('beta') or 1.0),
            "pe": float(info.get('trailingPE') or 20.0),
            "change": float(info.get('regularMarketChangePercent') or 0.0),
        }
    except Exception as e:
        print(f"yfinance error for {ticker}: {e}")
        return None


# ── Helper: build Claude prompt ────────────────────────────────────────────────

def build_prompt(holdings_data: list, total_value: float) -> str:
    summary = []
    for h in holdings_data:
        allocation = (h['value'] / total_value * 100) if total_value else 0
        summary.append({
            "ticker":     h['ticker'],
            "sector":     h['sector'],
            "allocation": f"{allocation:.1f}%",
            "beta":       h['beta'],
            "pe":         h['pe'],
            "gain":       f"{h['gain']:.1f}%",
        })

    return f"""You are a sharp, honest financial analyst. Analyze this portfolio and respond ONLY with a valid JSON object — no markdown, no extra text.

Portfolio:
{json.dumps(summary, indent=2)}

Total Value: ${total_value:,.2f}

Return exactly this structure:
{{
  "risk_score": <number 1-10>,
  "diversification_grade": "<A|B|C|D|F>",
  "insights": ["<insight 1>", "<insight 2>", "<insight 3>"],
  "recommendations": ["<action 1>", "<action 2>", "<action 3>"],
  "weaknesses": ["<weakness 1>", "<weakness 2>"]
}}"""


# ── Helper: parse Claude response ─────────────────────────────────────────────

def parse_claude_response(text: str) -> dict:
    try:
        start = text.find('{')
        end   = text.rfind('}') + 1
        if start != -1 and end > start:
            return json.loads(text[start:end])
    except Exception as e:
        print(f"JSON parse error: {e}")
    return {
        "risk_score": 5,
        "diversification_grade": "C",
        "insights": ["Analysis completed."],
        "recommendations": ["Review your portfolio allocation."],
        "weaknesses": ["Unable to parse detailed analysis."],
    }


# ── Routes ─────────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "PortfolioIQ Backend", "status": "running"}


@app.get("/api/market-data/{ticker}")
def get_market_data(ticker: str):
    data = fetch_market_data(ticker.upper())
    if not data:
        raise HTTPException(status_code=404, detail=f"Could not fetch data for {ticker}")
    return data


@app.post("/api/analyze-portfolio", response_model=PortfolioAnalysisResponse)
def analyze_portfolio(request: AnalyzeRequest):
    # Enrich each holding with live market data
    enriched = []
    for h in request.holdings:
        market = fetch_market_data(h.ticker.upper())
        if market and market['price'] > 0:
            price = market['price']
            sector = market['sector']
            beta   = market['beta']
            pe     = market['pe']
            change = market['change']
        else:
            price  = h.avgPrice * 1.05
            sector = 'Unknown'
            beta   = 1.0
            pe     = 20.0
            change = 0.0

        gain  = ((price - h.avgPrice) / h.avgPrice * 100) if h.avgPrice else 0.0
        value = price * h.shares

        enriched.append({
            "ticker":   h.ticker,
            "shares":   h.shares,
            "avgPrice": h.avgPrice,
            "price":    price,
            "sector":   sector,
            "beta":     beta,
            "pe":       pe,
            "change":   change,
            "gain":     gain,
            "value":    value,
        })

    total_value = sum(e['value'] for e in enriched)
    prompt      = build_prompt(enriched, total_value)

    try:
        message = anthropic_client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[{"role": "user", "content": prompt}],
        )
        raw  = message.content[0].text
        data = parse_claude_response(raw)
    except Exception as e:
        print(f"Claude API error: {e}")
        raise HTTPException(status_code=500, detail=f"AI analysis failed: {e}")

    return PortfolioAnalysisResponse(
        risk_score            = float(data.get('risk_score', 5)),
        diversification_grade = str(data.get('diversification_grade', 'C')),
        insights              = list(data.get('insights', [])),
        recommendations       = list(data.get('recommendations', [])),
        weaknesses            = list(data.get('weaknesses', [])),
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000)
