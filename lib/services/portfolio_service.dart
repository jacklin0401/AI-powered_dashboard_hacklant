// lib/services/portfolio_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/holding.dart';

const Map<String, Map<String, dynamic>> mockMarketData = {
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

class PortfolioService {
  static List<Holding> enrichHoldings(List<Holding> holdings) {
    return holdings.map((h) {
      final market = mockMarketData[h.ticker] ??
          {
            'price': h.avgPrice * 1.1,
            'sector': 'Unknown',
            'beta': 1.2,
            'pe': 25.0,
            'change': 0.0,
          };
      return h.copyWithMarketData(
        price: (market['price'] as num).toDouble(),
        sector: market['sector'] as String,
        beta: (market['beta'] as num).toDouble(),
        pe: (market['pe'] as num).toDouble(),
        change: (market['change'] as num).toDouble(),
      );
    }).toList();
  }

  static Future<PortfolioAnalysis> analyzeWithClaude(List<Holding> enriched) async {
    final totalValue = enriched.fold(0.0, (s, h) => s + h.value);
    final summary = enriched.map((h) => {
      'ticker': h.ticker,
      'sector': h.sector,
      'allocation': '${((h.value / totalValue) * 100).toStringAsFixed(1)}%',
      'beta': h.beta,
      'pe': h.pe,
      'gain': '${h.gain.toStringAsFixed(1)}%',
    }).toList();

    final prompt = '''You are a sharp, honest financial analyst. Analyze this portfolio and respond ONLY with a valid JSON object (no markdown, no extra text):

Portfolio: ${jsonEncode(summary)}
Total Value: \$${totalValue.toStringAsFixed(2)}

Return exactly this JSON structure:
{
  "riskScore": <number 1-10>,
  "diversificationGrade": "<letter A/B/C/D/F>",
  "diversificationNote": "<one sentence why>",
  "redFlag": "<one sentence biggest concern or null>",
  "moves": ["<move 1>", "<move 2>", "<move 3>"],
  "summary": "<2 sentence overall assessment>",
  "verdict": "<5 word max punchy verdict>"
}''';

    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'model': 'claude-sonnet-4-20250514',
        'max_tokens': 1000,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (data['content'] as List)
        .map((b) => (b as Map)['text'] ?? '')
        .join('');
    final clean = content.replaceAll(RegExp(r'```json|```'), '').trim();
    final parsed = jsonDecode(clean) as Map<String, dynamic>;
    return PortfolioAnalysis.fromJson(parsed);
  }
}
