import 'package:flutter/material.dart';
import 'presentation/widgets/app_drawer.dart';

/// Data: AppShellAction - representa una acción del AppBar
class AppShellAction {
  final String label;
  final IconData icon;
  final VoidCallback onSelected;

  const AppShellAction({
    required this.label,
    required this.icon,
    required this.onSelected,
  });
}

/// Widget: AppShell - estructura base con AppBar y Drawer.
class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<AppShellAction> actions;
  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalendario;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.onGoToCalculadora,
    required this.onGoToCalendario,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        onGoToCalculadora: onGoToCalculadora,
        onGoToCalendario: onGoToCalendario,
      ),
      appBar: AppBar(
        title: Text(title),
        actions: actions.isEmpty
            ? null
            : [
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (index) => actions[index].onSelected(),
                  itemBuilder: (ctx) => [
                    for (int i = 0; i < actions.length; i++)
                      PopupMenuItem<int>(
                        value: i,
                        child: Row(
                          children: [
                            Icon(actions[i].icon, size: 20),
                            const SizedBox(width: 8),
                            Text(actions[i].label),
                          ],
                        ),
                      ),
                  ],
                )
              ],
      ),
      body: body,
    );
  }
}
