// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() {
  runApp(const PortfolioIQApp());
}

class PortfolioIQApp extends StatelessWidget {
  const PortfolioIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PortfolioIQ',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const HomeScreen(),
    );
  }
}
