import 'package:flutter/material.dart';

/// Widget: AppDrawer - menú lateral de navegación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onGoToCalculadora,
    required this.onGoToCalendario,
  });

  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalendario;

  /// Función: _go - ejecuta el callback y cierra el drawer.
  void _go(BuildContext context, VoidCallback callback) {
    Navigator.pop(context); // cierra el drawer
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Calcular precio del oro'),
              onTap: () => _go(context, onGoToCalculadora),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendario minero'),
              onTap: () => _go(context, onGoToCalendario),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('Biblioteca Minera'),
              onTap: () {}, // TODO
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Consultoría personalizada'),
              onTap: () {}, // TODO
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración de la cuenta'),
              onTap: () {}, // TODO
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Dejar feedback sobre la app'),
              onTap: () {}, // TODO
            ),
          ],
        ),
      ),
    );
  }
}