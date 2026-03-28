// lib/services/portfolio_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holding.dart';

// Backend API configuration
// priority: .env variable -> --dart-define -> default
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getBackendBaseUrl() {
  final envUrl = dotenv.env['API_BASE_URL'];
  if (envUrl != null && envUrl.isNotEmpty) {
    return envUrl;
  }

  // For compile-time override
  final defineUrl = String.fromEnvironment('API_BASE_URL');
  if (defineUrl.isNotEmpty) {
    return defineUrl;
  }

  return 'http://localhost:8000';
}

class PortfolioService {
  // Fallback mock data for when backend is unavailable
  static const Map<String, Map<String, dynamic>> mockMarketData = {
    'AAPL': {'price': 213.49, 'sector': 'Technology', 'beta': 1.24, 'pe': 33.2, 'change': 1.2},
    'TSLA': {'price': 248.23, 'sector': 'Consumer Cyclical', 'beta': 2.11, 'pe': 68.4, 'change': -2.3},
    'NVDA': {'price': 875.4, 'sector': 'Technology', 'beta': 1.89, 'pe': 72.1, 'change': 3.1},
    'SPY': {'price': 524.8, 'sector': 'Index Fund', 'beta': 1.0, 'pe': 22.5, 'change': 0.4},
    'AMZN': {'price': 189.32, 'sector': 'Consumer Cyclical', 'beta': 1.45, 'pe': 44.8, 'change': 0.8},
    'MSFT': {'price': 415.2, 'sector': 'Technology', 'beta': 0.9, 'pe': 36.1, 'change': 0.6},
    'GOOGL': {'price': 172.63, 'sector': 'Communication Services', 'beta': 1.05, 'pe': 24.3, 'change': -0.4},
    'META': {'price': 512.77, 'sector': 'Communication Services', 'beta': 1.32, 'pe': 28.7, 'change': 1.9},
    'JPM': {'price': 198.45, 'sector': 'Financial Services', 'beta': 1.12, 'pe': 12.1, 'change': 0.3},
    'BRK': {'price': 384.2, 'sector': 'Financial Services', 'beta': 0.87, 'pe': 10.8, 'change': 0.1},
  };

  static Future<List<Holding>> enrichHoldings(List<Holding> holdings) async {
    try {
      // Try to enrich from backend first
      return await _enrichFromBackend(holdings);
    } catch (e) {
      print('Backend unavailable, using mock data: $e');
      // Fallback to mock data
      return _enrichWithMockData(holdings);
    }
  }

  static Future<List<Holding>> _enrichFromBackend(List<Holding> holdings) async {
    List<Holding> enriched = [];

    for (final holding in holdings) {
      try {
        final backendUrl = getBackendBaseUrl();
        final response = await http.get(
          Uri.parse('$backendUrl/api/market-data/${holding.ticker}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final currentPrice = data['price'] ?? holding.avgPrice;
          final gain = ((currentPrice - holding.avgPrice) / holding.avgPrice) * 100;

          enriched.add(holding.copyWithMarketData(
            price: currentPrice.toDouble(),
            sector: data['sector'] ?? 'Unknown',
            beta: (data['beta'] ?? 1.0).toDouble(),
            pe: (data['pe'] ?? 20.0).toDouble(),
            change: (data['change'] ?? 0.0).toDouble(),
            gain: gain,
          ));
        } else {
          // If backend fails for this ticker, use mock data
          enriched.add(_enrichSingleHoldingWithMock(holding));
        }
      } catch (e) {
        print('Error fetching ${holding.ticker}: $e');
        enriched.add(_enrichSingleHoldingWithMock(holding));
      }
    }

    return enriched;
  }

  static List<Holding> _enrichWithMockData(List<Holding> holdings) {
    return holdings.map(_enrichSingleHoldingWithMock).toList();
  }

  static Holding _enrichSingleHoldingWithMock(Holding holding) {
    final market = mockMarketData[holding.ticker] ??
        {
          'price': holding.avgPrice * 1.1,
          'sector': 'Unknown',
          'beta': 1.2,
          'pe': 25.0,
          'change': 0.0,
        };

    final currentPrice = (market['price'] as num).toDouble();
    final gain = ((currentPrice - holding.avgPrice) / holding.avgPrice) * 100;

    return holding.copyWithMarketData(
      price: currentPrice,
      sector: market['sector'] as String,
      beta: (market['beta'] as num).toDouble(),
      pe: (market['pe'] as num).toDouble(),
      change: (market['change'] as num).toDouble(),
      gain: gain,
    );
  }

  static Future<PortfolioAnalysis> analyzeWithClaude(List<Holding> enriched) async {
    try {
      // Try backend API first
      final holdingsData = enriched.map((h) => {
        'ticker': h.ticker,
        'shares': h.shares,
        'avgPrice': h.avgPrice,
      }).toList();

      final backendUrl = getBackendBaseUrl();
      final response = await http.post(
        Uri.parse('$backendUrl/api/analyze-portfolio'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'holdings': holdingsData}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PortfolioAnalysis(
          riskScore: (data['risk_score'] ?? 5.0).toDouble(),
          diversificationGrade: data['diversification_grade'] ?? 'C',
          diversificationNote: data['insights']?.join('. ') ?? 'Analysis completed',
          redFlag: data['weaknesses']?.isNotEmpty == true ? data['weaknesses'][0] : null,
          moves: List<String>.from(data['recommendations'] ?? []),
          summary: data['insights']?.join('. ') ?? 'Portfolio analysis completed',
          verdict: 'AI Analysis Complete',
        );
      } else {
        throw Exception('Backend API error: ${response.statusCode}');
      }
    } catch (e) {
      print('Backend analysis failed, using fallback: $e');
      // Fallback to mock analysis
      return _mockAnalysis(enriched);
    }
  }

  static PortfolioAnalysis _mockAnalysis(List<Holding> enriched) {
    final totalValue = enriched.fold(0.0, (s, h) => s + h.value);
    final sectors = enriched.map((h) => h.sector).toSet();

    String grade = 'C';
    if (sectors.length >= 5) grade = 'A';
    else if (sectors.length >= 3) grade = 'B';
    else if (sectors.length <= 1) grade = 'F';

    return PortfolioAnalysis(
      riskScore: 5.0,
      diversificationGrade: grade,
      diversificationNote: 'Mock analysis - connect to backend for real AI insights',
      redFlag: sectors.length <= 2 ? 'Limited sector diversification' : null,
      moves: [
        'Consider adding exposure to different sectors',
        'Review individual stock concentrations',
        'Monitor portfolio performance regularly'
      ],
      summary: 'This is a mock analysis. Start the backend server for real AI-powered insights.',
      verdict: 'Mock Analysis',
    );
  }
}
