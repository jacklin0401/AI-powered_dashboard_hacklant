// lib/widgets/charts_tab.dart
// Uses only Flutter built-ins (CustomPainter) — no fl_chart dependency needed.
import 'dart:math';
import 'package:flutter/material.dart';
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
          // Donut chart
          _Card(
            label: 'SECTOR ALLOCATION',
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      values: sectorList.map((e) => e.value).toList(),
                      colors: List.generate(
                          sectorList.length,
                          (i) => kSectorColors[i % kSectorColors.length]),
                    ),
                    child: Center(
                      child: Text(
                        '${sectorList.length}\nsectors',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: kMuted, height: 1.4),
                      ),
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
                              color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${e.value.key}  ${e.value.value.toStringAsFixed(1)}%',
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

          // Bar chart
          _Card(
            label: 'GAIN / LOSS BY POSITION',
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _BarPainter(holdings: enriched),
                size: Size.infinite,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String label;
  final Widget child;
  const _Card({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final total = values.fold(0.0, (a, b) => a + b);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = min(cx, cy) - 8;
    final ringR = (outerR + outerR * 0.55) / 2;
    final strokeW = outerR - outerR * 0.55;

    double startAngle = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: ringR),
        startAngle + 0.04,
        sweep - 0.08,
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => false;
}

class _BarPainter extends CustomPainter {
  final List<Holding> holdings;
  _BarPainter({required this.holdings});

  @override
  void paint(Canvas canvas, Size size) {
    if (holdings.isEmpty) return;

    const labelH = 24.0;
    const yAxisW = 44.0;
    final chartW = size.width - yAxisW;
    final chartH = size.height - labelH;

    final maxAbs = holdings.map((h) => h.gain.abs()).fold(0.0, (a, b) => a > b ? a : b);
    final scale = maxAbs < 1 ? 10.0 : maxAbs * 1.35;
    final zeroY = chartH / 2;

    // Zero line
    canvas.drawLine(
      Offset(yAxisW, zeroY), Offset(size.width, zeroY),
      Paint()..color = Colors.white.withOpacity(0.15)..strokeWidth = 1,
    );

    // Grid + Y labels
    for (final pct in [-0.5, 0.5]) {
      final y = zeroY - pct * zeroY;
      canvas.drawLine(
        Offset(yAxisW, y), Offset(size.width, y),
        Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1,
      );
      _drawText(canvas, '${(pct * scale).toStringAsFixed(0)}%',
          Offset(0, y), 9, const Color(0xFF666666));
    }

    // Bars
    final gap = chartW / holdings.length;
    final barW = gap * 0.5;

    for (var i = 0; i < holdings.length; i++) {
      final h = holdings[i];
      final barH = ((h.gain.abs() / scale) * zeroY).clamp(1.0, zeroY);
      final x = yAxisW + gap * i + gap / 2 - barW / 2;
      final color = h.gain >= 0 ? kGreen : kRed;

      final top = h.gain >= 0 ? zeroY - barH : zeroY;
      final rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, barW, barH),
        topLeft: h.gain >= 0 ? const Radius.circular(4) : Radius.zero,
        topRight: h.gain >= 0 ? const Radius.circular(4) : Radius.zero,
        bottomLeft: h.gain < 0 ? const Radius.circular(4) : Radius.zero,
        bottomRight: h.gain < 0 ? const Radius.circular(4) : Radius.zero,
      );
      canvas.drawRRect(rr, Paint()..color = color);

      // Gain label
      final gainStr = '${h.gain >= 0 ? '+' : ''}${h.gain.toStringAsFixed(1)}%';
      final glY = h.gain >= 0 ? top - 14 : top + barH + 2;
      _drawText(canvas, gainStr, Offset(x + barW / 2, glY.clamp(0, chartH - 12)),
          8, color, centered: true, bold: true);

      // Ticker
      _drawText(canvas, h.ticker,
          Offset(x + barW / 2, chartH + (labelH - 12) / 2), 10, kMuted,
          centered: true);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize,
      Color color, {bool centered = false, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centered ? Offset(offset.dx - tp.width / 2, offset.dy) : offset);
  }

  @override
  bool shouldRepaint(_BarPainter old) => false;
}
