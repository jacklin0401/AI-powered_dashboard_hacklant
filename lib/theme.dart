// lib/theme.dart
import 'package:flutter/material.dart';

const kGold = Color(0xFFC9A84C);
const kGoldLight = Color(0xFFE8C97A);
const kGoldDark = Color(0xFFA07830);
const kBg = Color(0xFF0D0A05);
const kSurface = Color(0xFF13100A);
const kBorder = Color(0x33C9A84C);
const kGreen = Color(0xFF4ADE80);
const kRed = Color(0xFFF87171);
const kOrange = Color(0xFFFB923C);
const kText = Color(0xFFE8E0D0);
const kMuted = Color(0xFF888888);

const List<Color> kSectorColors = [
  Color(0xFFC9A84C),
  Color(0xFFE8C97A),
  Color(0xFFF0DFA0),
  Color(0xFFA07830),
  Color(0xFF7A5820),
  Color(0xFF4A3010),
];

Color gradeColor(String grade) {
  switch (grade.isNotEmpty ? grade[0] : '') {
    case 'A': return kGreen;
    case 'B': return kGold;
    case 'C': return kOrange;
    case 'D':
    case 'F': return kRed;
    default: return kMuted;
  }
}

Color riskColor(int score) {
  if (score <= 3) return kGreen;
  if (score <= 6) return kGold;
  return kRed;
}

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      surface: kSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x10FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x33FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGold),
      ),
      hintStyle: const TextStyle(color: kMuted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}
