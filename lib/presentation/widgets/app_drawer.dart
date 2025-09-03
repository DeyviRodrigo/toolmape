import 'package:flutter/material.dart';
import '../../ui_kit/app_drawer_item.dart';

/// Widget: AppDrawer - menú lateral de navegación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onGoToCalculadora,
    required this.onGoToCalcularDescuento,
    required this.onGoToCalendario,
  });

  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalcularDescuento;
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
            AppDrawerItem(
              icon: Icons.calculate_outlined,
              title: 'Calcular precio del oro',
              onTap: () => _go(context, onGoToCalculadora),
            ),
            AppDrawerItem(
              icon: Icons.percent,
              title: 'Tengo el precio, quiero calcular el descuento',
              onTap: () => _go(context, onGoToCalcularDescuento),
            ),
            AppDrawerItem(
              icon: Icons.calendar_month,
              title: 'Calendario minero',
              onTap: () => _go(context, onGoToCalendario),
            ),
            AppDrawerItem(
              icon: Icons.menu_book_outlined,
              title: 'Biblioteca Minera',
              onTap: () { Navigator.pop(context); },
            ),
            AppDrawerItem(
              icon: Icons.support_agent,
              title: 'Consultoría personalizada',
              onTap: () { Navigator.pop(context); },
            ),
            const Divider(),
            AppDrawerItem(
              icon: Icons.settings,
              title: 'Configuración de la cuenta',
              onTap: () { Navigator.pop(context); },
            ),
            AppDrawerItem(
              icon: Icons.feedback_outlined,
              title: 'Dejar feedback sobre la app',
              onTap: () { Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}
