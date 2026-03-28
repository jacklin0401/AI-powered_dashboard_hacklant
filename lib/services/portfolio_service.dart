// lib/services/portfolio_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/holding.dart';

String getBackendBaseUrl() {
  final envUrl = dotenv.env['API_BASE_URL'];
  if (envUrl != null && envUrl.isNotEmpty) return envUrl;
  const defineUrl = String.fromEnvironment('API_BASE_URL');
  if (defineUrl.isNotEmpty) return defineUrl;
  return 'http://localhost:8000';
}

class PortfolioService {
  static const Map<String, Map<String, dynamic>> _mockMarketData = {
    'AAPL': {'price': 213.49, 'sector': 'Technology', 'beta': 1.24, 'pe': 33.2, 'change': 1.2},
    'TSLA': {'price': 248.23, 'sector': 'Consumer Cyclical', 'beta': 2.11, 'pe': 68.4, 'change': -2.3},
    'NVDA': {'price': 875.4,  'sector': 'Technology', 'beta': 1.89, 'pe': 72.1, 'change': 3.1},
    'SPY':  {'price': 524.8,  'sector': 'Index Fund', 'beta': 1.0,  'pe': 22.5, 'change': 0.4},
    'AMZN': {'price': 189.32, 'sector': 'Consumer Cyclical', 'beta': 1.45, 'pe': 44.8, 'change': 0.8},
    'MSFT': {'price': 415.2,  'sector': 'Technology', 'beta': 0.9,  'pe': 36.1, 'change': 0.6},
    'GOOGL':{'price': 172.63, 'sector': 'Communication Services', 'beta': 1.05, 'pe': 24.3, 'change': -0.4},
    'META': {'price': 512.77, 'sector': 'Communication Services', 'beta': 1.32, 'pe': 28.7, 'change': 1.9},
    'JPM':  {'price': 198.45, 'sector': 'Financial Services', 'beta': 1.12, 'pe': 12.1, 'change': 0.3},
    'BRK':  {'price': 384.2,  'sector': 'Financial Services', 'beta': 0.87, 'pe': 10.8, 'change': 0.1},
  };

  // ── Enrich holdings: try backend first, fall back to mock ─────────────────
  static Future<List<Holding>> enrichHoldings(List<Holding> holdings) async {
    try {
      return await _enrichFromBackend(holdings);
    } catch (e) {
      print('Backend unavailable, using mock data: $e');
      return _enrichWithMock(holdings);
    }
  }

  static Future<List<Holding>> _enrichFromBackend(List<Holding> holdings) async {
    final results = <Holding>[];
    for (final h in holdings) {
      try {
        final url = '${getBackendBaseUrl()}/api/market-data/${h.ticker}';
        final res = await http
            .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
            .timeout(const Duration(seconds: 5));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          results.add(h.copyWithMarketData(
            price:  (data['price']  as num?)?.toDouble() ?? h.avgPrice,
            sector: (data['sector'] as String?) ?? 'Unknown',
            beta:   (data['beta']   as num?)?.toDouble() ?? 1.0,
            pe:     (data['pe']     as num?)?.toDouble() ?? 20.0,
            change: (data['change'] as num?)?.toDouble() ?? 0.0,
          ));
        } else {
          results.add(_enrichOneMock(h));
        }
      } catch (_) {
        results.add(_enrichOneMock(h));
      }
    }
    return results;
  }

  static List<Holding> _enrichWithMock(List<Holding> holdings) =>
      holdings.map(_enrichOneMock).toList();

  static Holding _enrichOneMock(Holding h) {
    final m = _mockMarketData[h.ticker] ?? {
      'price': h.avgPrice * 1.1,
      'sector': 'Unknown',
      'beta': 1.2,
      'pe': 25.0,
      'change': 0.0,
    };
    return h.copyWithMarketData(
      price:  (m['price']  as num).toDouble(),
      sector: m['sector']  as String,
      beta:   (m['beta']   as num).toDouble(),
      pe:     (m['pe']     as num).toDouble(),
      change: (m['change'] as num).toDouble(),
    );
  }

  // ── Analyze: try backend first, fall back to mock ─────────────────────────
  static Future<PortfolioAnalysis> analyzeWithClaude(List<Holding> enriched) async {
    try {
      final body = jsonEncode({
        'holdings': enriched.map((h) => {
          'ticker': h.ticker,
          'shares': h.shares,
          'avgPrice': h.avgPrice,
        }).toList(),
      });

      final res = await http
          .post(
            Uri.parse('${getBackendBaseUrl()}/api/analyze-portfolio'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;

        // Map backend snake_case response → PortfolioAnalysis
        final insights      = List<String>.from(data['insights']       ?? []);
        final recommendations = List<String>.from(data['recommendations'] ?? []);
        final weaknesses    = List<String>.from(data['weaknesses']     ?? []);
        final redFlag       = weaknesses.isNotEmpty ? weaknesses.first : null;
        final grade         = data['diversification_grade'] as String? ?? 'C';
        final riskScore     = (data['risk_score'] as num?)?.toInt() ?? 5;
        final note          = insights.isNotEmpty ? insights.first : 'Analysis complete.';
        final summary       = insights.take(2).join(' ');

        return PortfolioAnalysis(
          riskScore: riskScore,
          diversificationGrade: grade,
          diversificationNote: note,
          redFlag: redFlag,
          moves: recommendations,
          summary: summary.isNotEmpty ? summary : 'Portfolio analysis complete.',
          verdict: _verdictFromScore(riskScore, grade),
        );
      }
      throw Exception('Backend returned ${res.statusCode}');
    } catch (e) {
      print('Backend analysis failed, using fallback: $e');
      return _mockAnalysis(enriched);
    }
  }

  static String _verdictFromScore(int risk, String grade) {
    if (risk <= 3 && (grade == 'A' || grade == 'B')) return 'Well balanced & low risk';
    if (risk >= 8) return 'High risk — rebalance now';
    if (grade == 'F' || grade == 'D') return 'Dangerously concentrated';
    return 'Moderate — room to improve';
  }

  static PortfolioAnalysis _mockAnalysis(List<Holding> enriched) {
    final sectors = enriched.map((h) => h.sector).toSet();
    String grade = 'C';
    if (sectors.length >= 5) grade = 'A';
    else if (sectors.length >= 3) grade = 'B';
    else if (sectors.length <= 1) grade = 'F';

    return PortfolioAnalysis(
      riskScore: 5,
      diversificationGrade: grade,
      diversificationNote:
          'Mock analysis — start the backend for real AI insights.',
      redFlag: sectors.length <= 2 ? 'Limited sector diversification detected.' : null,
      moves: [
        'Consider adding exposure to different sectors.',
        'Review individual stock concentration levels.',
        'Monitor portfolio performance regularly.',
      ],
      summary:
          'This is a mock analysis. Start the Python backend for real AI-powered insights.',
      verdict: 'Mock Analysis',
    );
  }
}
