import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    );
  }
}
