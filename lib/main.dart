// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'backend/.env');

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
