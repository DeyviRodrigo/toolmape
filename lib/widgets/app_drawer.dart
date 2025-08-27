import 'package:flutter/material.dart';
import '../features/calculadora/calculadora_screen.dart';
import '../presentation/screens/calendario_screen.dart';

/// Widget: AppDrawer - menú lateral de navegación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  /// Función: _go - navega a la pantalla indicada.
  void _go(BuildContext context, Widget screen) {
    Navigator.pop(context); // cierra el drawer

    // Evita duplicar la misma ruta
    final current = ModalRoute.of(context)?.settings.name;
    final target  = screen.runtimeType.toString();
    if (current == target) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: target),
        builder: (_) => screen,
      ),
    );
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
              onTap: () => _go(context, const ScreenCalculadora()),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendario minero'),
              onTap: () => _go(context, const CalendarioMineroScreen()),
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