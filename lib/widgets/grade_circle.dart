// lib/widgets/grade_circle.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class GradeCircle extends StatelessWidget {
  final String grade;
  final String label;

  const GradeCircle({super.key, required this.grade, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = gradeColor(grade);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
            color: color.withOpacity(0.08),
            boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 20, spreadRadius: 2)],
          ),
          child: Center(
            child: Text(
              grade,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w800, color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 9, color: kMuted, letterSpacing: 1.5),
        ),
      ],
    );
  }
}
