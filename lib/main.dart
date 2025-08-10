// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/calculadora_screen.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScreenCalculadora()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2E2B2B),
      body: Center(
        child: Image(
          image: AssetImage('assets/LoadingTrazMAPE.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}