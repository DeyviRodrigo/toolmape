import 'package:flutter/material.dart';
import 'features/calculadora/calculadora_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToolMAPEApp());
}

class ToolMAPEApp extends StatelessWidget {
  const ToolMAPEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToolMAPE',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFC107), // amber-ish
      ),
      home: const ScreenCalculadora(),
    );
  }
}
