import 'package:flutter/material.dart';
import 'package:toolmape/features/general/presentation/molecules/app_drawer_item.dart';
import 'package:toolmape/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget: AppDrawer - menú lateral de navegación.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onGoToCalculadora,
    required this.onGoToCalendario,
  });

  final VoidCallback onGoToCalculadora;
  final VoidCallback onGoToCalendario;

  void _go(BuildContext context, VoidCallback callback) {
    Navigator.pop(context);
    callback();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final user = Supabase.instance.client.auth.currentUser;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con icono SVG a la izquierda y colores según tema
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
                      child: Stack(
                        alignment: Alignment.center, // centra el contenido por defecto
                        children: [
                          // Logo alineado a la izquierda
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: SvgPicture.asset(
                                'assets/logo_ToolMAPE.svg',
                                theme: SvgTheme(
                                  currentColor: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          // Texto centrado
                          Text(
                            'ToolMAPE',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ],
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
                        onTap: () => Navigator.pop(context),
                      ),
                      AppDrawerItem(
                        icon: Icons.support_agent,
                        title: 'Consultoría personalizada',
                        onTap: () => Navigator.pop(context),
                      ),
                      const Divider(
                        height: 1,
                        color: Colors.grey,
                        thickness: 1,
                      ),
                      AppDrawerItem(
                        icon: Icons.info_outline,
                        title: 'Información de la app',
                        onTap: () => Navigator.pop(context),
                      ),
                      AppDrawerItem(
                        icon: Icons.comment_outlined,
                        title: 'Dejar comentarios',
                        onTap: () => Navigator.pop(context),
                      ),
                      AppDrawerItem(
                        icon: Icons.share,
                        title: 'Compartir aplicativo',
                        onTap: () => Navigator.pop(context),
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
                  ),
                ),
                const Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 1,
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user?.email ?? 'Iniciar sesión'),
                  trailing: user == null
                      ? null
                      : PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    onSelected: (v) async {
                      Navigator.pop(context);
                      if (v == 'logout') {
                        await Supabase.instance.client.auth.signOut();
                      }
                    },
                    itemBuilder: (_) => const [
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
                  onTap: user == null
                      ? () {
                    Navigator.pop(context);
                  }
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}