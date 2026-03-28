// lib/widgets/risk_meter.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class RiskMeter extends StatelessWidget {
  final int score;
  const RiskMeter({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final color = riskColor(score);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _ArcPainter(score: score, color: color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26, fontWeight: FontWeight.w800, color: color,
                    ),
                  ),
                  Text('/10', style: TextStyle(fontSize: 9, color: kMuted, letterSpacing: 1)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'RISK SCORE',
          style: TextStyle(fontSize: 9, color: kMuted, letterSpacing: 1.5),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final int score;
  final Color color;
  _ArcPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 42.0;
    const strokeWidth = 8.0;
    const startAngle = pi * 0.75;
    const sweepAngle = pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, bgPaint,
    );

    // Foreground arc
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * (score / 10), false, fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.score != score;
}
