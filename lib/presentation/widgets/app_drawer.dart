import 'package:flutter/material.dart';
import '../../ui_kit/app_drawer_item.dart';

/// Widget: AppDrawer - menú lateral de navegación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onGoToCalculadora,
    required this.onGoToCalendario,
    this.username,
  });

  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalendario;
  final String? username;

  /// Función: _go - ejecuta el callback y cierra el drawer.
  void _go(BuildContext context, VoidCallback callback) {
    Navigator.pop(context); // cierra el drawer
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final userLabel = username ?? 'Iniciar sesión';
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text(
                'ToolMAPE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  AppDrawerItem(
                    icon: Icons.calculate_outlined,
                    title: 'Calcular precio del oro',
                    onTap: () => _go(context, onGoToCalculadora),
                  ),
                  AppDrawerItem(
                    icon: Icons.calendar_month,
                    title: 'Calendario minero',
                    onTap: () => _go(context, onGoToCalendario),
                  ),
                  AppDrawerItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Biblioteca Minera',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.support_agent,
                    title: 'Consultoría personalizada',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(),
                  AppDrawerItem(
                    icon: Icons.info_outline,
                    title: 'Información de la app',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.comment_outlined,
                    title: 'Dejar comentarios',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  AppDrawerItem(
                    icon: Icons.share_outlined,
                    title: 'Compartir aplicativo',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(userLabel),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.arrow_drop_up),
                onSelected: (value) {
                  Navigator.pop(context);
                  // TODO: manejar acciones de la cuenta
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'config',
                    child: Text('Configurar la cuenta'),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Cerrar sesión'),
                  ),
                ],
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
