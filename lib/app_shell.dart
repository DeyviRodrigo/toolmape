import 'package:flutter/material.dart';
import 'presentation/widgets/app_drawer.dart';

/// Widget: AppShell - estructura base con AppBar y Drawer.
class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalcularDescuento;
  final VoidCallback onGoToCalendario;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.onGoToCalculadora,
    required this.onGoToCalcularDescuento,
    required this.onGoToCalendario,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onGoToCalculadora: onGoToCalculadora,
        onGoToCalcularDescuento: onGoToCalcularDescuento,
        onGoToCalendario: onGoToCalendario,
      ),
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    );
  }
}
