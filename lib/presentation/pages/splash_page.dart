import 'package:flutter/material.dart';
import 'package:toolmape/app/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, routeCalculadora);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _SplashImage(),
            SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashImage extends StatelessWidget {
  const _SplashImage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePath = isDark
        ? 'assets/TrazMAPE1.png'
        : 'assets/TrazMAPE2.png';
    return Image.asset(imagePath, width: 200);
  }
}

