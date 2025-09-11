import 'package:flutter/material.dart';
import 'package:toolmape/app/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )
      ..addListener(() => setState(() {}))
      ..forward().whenComplete(
          () => Navigator.pushReplacementNamed(context, routeCalculadora));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (_controller.value * 100).round();
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SplashImage(),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: _controller.value),
            ),
            const SizedBox(height: 8),
            Text('$progress%'),
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

