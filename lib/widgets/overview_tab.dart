// lib/widgets/overview_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/holding.dart';
import '../theme.dart';
import 'grade_circle.dart';
import 'risk_meter.dart';

class OverviewTab extends StatelessWidget {
  final List<Holding> enriched;
  final PortfolioAnalysis analysis;

  const OverviewTab({super.key, required this.enriched, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final totalValue = enriched.fold(0.0, (s, h) => s + h.value);
    final avgBeta = enriched.fold(0.0, (s, h) => s + h.beta) / enriched.length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Verdict banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1208), Color(0xFF13100A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: kGold.withOpacity(0.35)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI VERDICT', style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 2)),
                const SizedBox(height: 6),
                Text(
                  analysis.verdict,
                  style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(analysis.summary,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), height: 1.6)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GradeCircle(grade: analysis.diversificationGrade, label: 'Diversif.'),
                    RiskMeter(score: analysis.riskScore),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _StatCard(icon: '💰', value: '\$${_fmt(totalValue)}', label: 'Total Value'),
              const SizedBox(width: 10),
              _StatCard(icon: '📊', value: '${enriched.length}', label: 'Positions'),
              const SizedBox(width: 10),
              _StatCard(icon: '⚡', value: avgBeta.toStringAsFixed(2), label: 'Avg Beta'),
            ],
          ),

          const SizedBox(height: 14),

          // Holdings table
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: ['TICKER', 'SECTOR', 'VALUE', 'GAIN', 'BETA']
                        .map((h) => Expanded(
                              child: Text(h,
                                  style: TextStyle(fontSize: 9, color: Color(0xFF666666), letterSpacing: 1.5)),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(height: 1, color: Color(0x15C9A84C)),
                ...enriched.asMap().entries.map((e) {
                  final i = e.key;
                  final h = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(h.ticker,
                                  style: GoogleFonts.dmMono(
                                      fontSize: 13, fontWeight: FontWeight.w700, color: kGold)),
                            ),
                            Expanded(
                              child: Text(h.sector,
                                  style: const TextStyle(fontSize: 11, color: kMuted),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              child: Text('\$${h.value.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 12, color: kText)),
                            ),
                            Expanded(
                              child: Text(
                                '${h.gain >= 0 ? '+' : ''}${h.gain.toStringAsFixed(1)}%',
                                style: GoogleFonts.dmMono(
                                    fontSize: 12, color: h.gain >= 0 ? kGreen : kRed),
                              ),
                            ),
                            Expanded(
                              child: Text(h.beta.toString(),
                                  style: GoogleFonts.dmMono(fontSize: 12, color: kMuted)),
                            ),
                          ],
                        ),
                      ),
                      if (i < enriched.length - 1)
                        const Divider(height: 1, color: Color(0x08FFFFFF)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(2);
  }
}

class _StatCard extends StatelessWidget {
  final String icon, value, label;
  const _StatCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(value,
                style: GoogleFonts.playfairDisplay(fontSize: 18, color: kGold),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: TextStyle(fontSize: 9, color: kMuted, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}
