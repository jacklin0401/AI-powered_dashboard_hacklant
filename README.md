
---

## 🧾 Summary

**PortfolioIQ** is an AI-powered portfolio analyzer that helps investors understand how strong—or risky—their stock holdings really are. By combining live market data with AI-driven insights, the app evaluates a user’s portfolio and delivers a clear risk score, diversification grade, key red flags, and actionable recommendations.

Instead of just showing what you own, PortfolioIQ tells you how well you’re positioned—and what to do next.

> Input your portfolio → get instant analysis → make smarter investment decisions.

## 🧰 Tech Stack

### 🖥️ Frontend
- **Flutter** — Cross-platform mobile app framework
- **Dart** — Programming language
- **Material Design** — UI components and theming
- **fl_chart** — Data visualization and charting
- **Google Fonts** — Typography

### 🧠 AI Analyzer Agent
- **Claude API (Anthropic)** — Portfolio analysis and insights

### 📈 Market Data
- **Alpha Vantage API** (planned)
- **Yahoo Finance** (fallback via yfinance, planned)
- **Mock data** (current implementation)

### 🔧 Core Dependencies
- **http** — API communication
- **cupertino_icons** — iOS-style icons

### 🚀 Deployment
- **Flutter Build** — Android APK, iOS IPA
- **Web deployment** — Flutter Web
- **Desktop** — Windows, macOS, Linux support

### 🛠️ Dev Tools
- **VS Code** — Primary IDE
- **Flutter SDK** — Development framework
- **Dart SDK** (^3.11.0)
- **Git + GitHub** — Version control

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

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (^3.11.0) — [Install Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK** (^3.11.0) — Included with Flutter
- **Android Studio** or **VS Code** with Flutter extensions
- **Android/iOS emulator** or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jacklin0401/AI-powered_dashboard_hacklant.git
   cd AI-powered_dashboard_hacklant
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

- **Android APK**: `flutter build apk --release`
- **iOS**: `flutter build ios --release`
- **Web**: `flutter build web --release`
- **Windows**: `flutter build windows --release`
- **macOS**: `flutter build macos --release`
- **Linux**: `flutter build linux --release`

### Testing
```bash
flutter test
```

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── theme.dart             # App theming
├── models/
│   └── holding.dart       # Portfolio holding model
├── screens/
│   └── home_screen.dart   # Main screen
├── services/
│   └── portfolio_service.dart  # Business logic & API calls
└── widgets/
    ├── charts_tab.dart    # Charts and visualizations
    ├── grade_circle.dart  # Risk grade display
    ├── holdings_panel.dart # Portfolio holdings list
    ├── insights_tab.dart  # AI insights panel
    ├── overview_tab.dart  # Portfolio overview
    └── risk_meter.dart    # Risk visualization
```

---
