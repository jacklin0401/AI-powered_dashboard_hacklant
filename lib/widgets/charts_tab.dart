// lib/widgets/charts_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/holding.dart';
import '../theme.dart';

class ChartsTab extends StatelessWidget {
  final List<Holding> enriched;
  const ChartsTab({super.key, required this.enriched});

  Map<String, double> get sectorAllocation {
    final totalValue = enriched.fold(0.0, (s, h) => s + h.value);
    final map = <String, double>{};
    for (final h in enriched) {
      map[h.sector] = (map[h.sector] ?? 0) + (h.value / totalValue * 100);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final sectors = sectorAllocation;
    final sectorList = sectors.entries.toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Sector Allocation Pie
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SECTOR ALLOCATION',
                    style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: sectorList.asMap().entries.map((e) {
                        final color = kSectorColors[e.key % kSectorColors.length];
                        return PieChartSectionData(
                          value: e.value.value,
                          color: color,
                          radius: 55,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: sectorList.asMap().entries.map((e) {
                    final color = kSectorColors[e.key % kSectorColors.length];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: color, borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${e.value.key} ${e.value.value.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 11, color: kMuted),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Gain/Loss Bar Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GAIN / LOSS BY POSITION',
                    style: TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: enriched.map((h) => h.gain.abs()).fold(0.0, (a, b) => a > b ? a : b) * 1.3 + 5,
                      minY: -(enriched.map((h) => h.gain.abs()).fold(0.0, (a, b) => a > b ? a : b) * 1.3 + 5),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF1A1208),
                          getTooltipItem: (group, _, rod, __) {
                            final h = enriched[group.x];
                            return BarTooltipItem(
                              '${h.ticker}\n${rod.toY >= 0 ? '+' : ''}${rod.toY.toStringAsFixed(1)}%',
                              TextStyle(color: rod.toY >= 0 ? kGreen : kRed, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= enriched.length) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(enriched[i].ticker,
                                    style: const TextStyle(fontSize: 10, color: kMuted)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 9, color: Color(0xFF666666)),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            const FlLine(color: Color(0x08FFFFFF), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: enriched.asMap().entries.map((e) {
                        final gain = e.value.gain;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: gain,
                              color: gain >= 0 ? kGreen : kRed,
                              width: 20,
                              borderRadius: gain >= 0
                                  ? const BorderRadius.vertical(top: Radius.circular(4))
                                  : const BorderRadius.vertical(bottom: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
