import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toolmape/app/router/routes.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SplashImage(),
            const SizedBox(height: 24),
            Text(
              'LOADING',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: LinearProgressIndicator(
                value: _controller.value,
                minHeight: 10,
                backgroundColor:
                    isDark ? Colors.white24 : Colors.black26,
                valueColor: AlwaysStoppedAnimation(
                    isDark ? Colors.white : Colors.black),
              ),
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
    final imagePath =
        isDark ? 'assets/TrazMAPE_dark.svg' : 'assets/TrazMAPE_light.svg';
    final width = MediaQuery.of(context).size.width * 0.8;
    return SvgPicture.asset(
      imagePath,
      width: width,
      semanticsLabel: 'Ilustración ToolMAPE',
    );
  }
}

