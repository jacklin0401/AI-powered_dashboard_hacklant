// lib/widgets/insights_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/holding.dart';
import '../theme.dart';

class InsightsTab extends StatelessWidget {
  final PortfolioAnalysis analysis;
  const InsightsTab({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Red flag
          if (analysis.redFlag != null && analysis.redFlag!.isNotEmpty && analysis.redFlag != 'null')
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kRed.withOpacity(0.06),
                border: Border.all(color: kRed.withOpacity(0.35)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RED FLAG',
                            style: TextStyle(fontSize: 10, color: kRed, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text(analysis.redFlag!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFFFCA5A5), height: 1.6)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Diversification
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.05),
              border: Border.all(color: kGold.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DIVERSIFICATION · GRADE ${analysis.diversificationGrade}',
                    style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(analysis.diversificationNote,
                    style: const TextStyle(fontSize: 13, color: Color(0xFFCCCCCC), height: 1.7)),
              ],
            ),
          ),

          // 3 Moves
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3 MOVES TO MAKE',
                    style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5)),
                const SizedBox(height: 14),
                ...analysis.moves.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [kGold, kGoldDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, fontWeight: FontWeight.w700, color: kBg),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(e.value,
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFFCCCCCC), height: 1.6)),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
