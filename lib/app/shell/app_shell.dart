import 'package:flutter/material.dart';
import 'package:toolmape/features/general/presentation/organisms/app_drawer.dart';
import 'package:toolmape/features/general/presentation/atoms/menu_option.dart';

/// Widget: AppShell - estructura base con AppBar y Drawer.
class AppShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<MenuOption<VoidCallback>> actions;
  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalendario;
  final VoidCallback onGoToInformacion;

  const AppShell({
    super.key,
    required this.title,
    required this.body,
    required this.onGoToCalculadora,
    required this.onGoToCalendario,
    required this.onGoToInformacion,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: AppDrawer(
        onGoToCalculadora: onGoToCalculadora,
        onGoToCalendario: onGoToCalendario,
        onGoToInformacion: onGoToInformacion,
      ),
      appBar: AppBar(
        title: Text(title),
        actions: actions.isEmpty
            ? null
            : (size.width >= size.height
                ? actions
                    .map(
                      (a) => IconButton(
                        tooltip: a.label,
                        onPressed: a.value,
                        icon: Icon(a.icon),
                      ),
                    )
                    .toList()
                : [
                    PopupMenuButton<VoidCallback>(
                      key: const Key('appShell_moreMenu'),
                      icon: const Icon(Icons.more_vert),
                      onSelected: (cb) => cb(),
                      itemBuilder: (_) => actions
                          .map(
                            (a) => PopupMenuItem<VoidCallback>(
                              value: a.value,
                              child: Row(
                                children: [
                                  Icon(a.icon, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(a.label)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ]),
      ),
      body: SafeArea(child: body),
    );
  }
}
