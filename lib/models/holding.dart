// lib/models/holding.dart

class Holding {
  final String ticker;
  final double shares;
  final double avgPrice;

  // Enriched market data
  final double price;
  final String sector;
  final double beta;
  final double pe;
  final double change;
  final double value;
  final double gain;

  Holding({
    required this.ticker,
    required this.shares,
    required this.avgPrice,
    this.price = 0,
    this.sector = 'Unknown',
    this.beta = 1.0,
    this.pe = 0,
    this.change = 0,
    this.value = 0,
    this.gain = 0,
  });

  Holding copyWithMarketData({
    required double price,
    required String sector,
    required double beta,
    required double pe,
    required double change,
  }) {
    final val = price * shares;
    final g = avgPrice > 0 ? ((price - avgPrice) / avgPrice * 100) : 0.0;
    return Holding(
      ticker: ticker,
      shares: shares,
      avgPrice: avgPrice,
      price: price,
      sector: sector,
      beta: beta,
      pe: pe,
      change: change,
      value: val,
      gain: g,
    );
  }
}

class PortfolioAnalysis {
  final int riskScore;
  final String diversificationGrade;
  final String diversificationNote;
  final String? redFlag;
  final List<String> moves;
  final String summary;
  final String verdict;

  PortfolioAnalysis({
    required this.riskScore,
    required this.diversificationGrade,
    required this.diversificationNote,
    this.redFlag,
    required this.moves,
    required this.summary,
    required this.verdict,
  });

  factory PortfolioAnalysis.fromJson(Map<String, dynamic> json) {
    return PortfolioAnalysis(
      riskScore: (json['riskScore'] as num).toInt(),
      diversificationGrade: json['diversificationGrade'] as String,
      diversificationNote: json['diversificationNote'] as String,
      redFlag: json['redFlag'] as String?,
      moves: List<String>.from(json['moves'] as List),
      summary: json['summary'] as String,
      verdict: json['verdict'] as String,
    );
  }
}
