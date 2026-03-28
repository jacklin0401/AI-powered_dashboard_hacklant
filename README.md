
---

## 🧾 Summary

**PortfolioIQ** is an AI-powered portfolio analyzer that helps investors understand how strong—or risky—their stock holdings really are. By combining live market data with AI-driven insights, the app evaluates a user’s portfolio and delivers a clear risk score, diversification grade, key red flags, and actionable recommendations.

Instead of just showing what you own, PortfolioIQ tells you how well you’re positioned—and what to do next.

> Input your portfolio → get instant analysis → make smarter investment decisions.

## 🧰 Tech Stack

### 🖥️ Frontend
- React
- Tailwind CSS
- Recharts (data visualization)
- Lucide React (icons)

### 🧠 AI
- Claude API (Anthropic) — portfolio analysis

### 📈 Market Data
- Alpha Vantage API (primary)
- Yahoo Finance (fallback via yfinance)

### ⚙️ Backend
- Node.js + Express **or** Python FastAPI
- Axios / Fetch for API calls

### 🚀 Deployment
- Vercel — frontend
- Railway / Render — backend

### 🛠️ Dev Tools
- VS Code
- Git + GitHub
- Postman

---

## ✨ Features

### 📥 Portfolio Input
- Add stock ticker, shares, and purchase price
- Pre-loaded sample portfolio for instant demo

### 🧠 AI Analysis
- Risk scoring
- Diversification grading
- Portfolio weaknesses detection
- Actionable investment suggestions

### 📊 Dashboard
- 🥧 Sector allocation pie chart  
- 📊 Stock performance bar chart  
- 🌡️ Risk meter visualization  
- 💬 AI insight panel  

### 🎯 Demo-Ready UX
- One-click **“Analyze My Portfolio”**
- Mobile-friendly
- “Roast My Portfolio” button for engagement

---

## 🪜 How It Works

1. **User enters portfolio**
2. **App fetches market data** for each stock
3. **Portfolio is enriched** with financial metrics:
   - Price
   - Sector
   - Beta
   - P/E ratio
   - 52-week performance
4. **Claude API analyzes the data**
5. **Results are rendered** in charts + insights

---
