import 'package:flutter/material.dart';
import 'package:toolmape/design_system/molecules/app_drawer_item.dart';
import 'package:toolmape/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        child: Consumer(
          builder: (context, ref, _) {
            return ListView(
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
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Tema'),
                  trailing: DropdownButton<String>(
                    value: ref.watch(themeProfileProvider).value ?? 'dark',
                    items: const [
                      DropdownMenuItem(value: 'dark', child: Text('Oscuro')),
                      DropdownMenuItem(value: 'light', child: Text('Claro')),
                      DropdownMenuItem(value: 'gold', child: Text('Dorado')),
                      DropdownMenuItem(value: 'black', child: Text('Black')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(themeProfileProvider.notifier).setTheme(v);
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
