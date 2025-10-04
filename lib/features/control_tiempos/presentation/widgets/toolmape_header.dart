import 'package:flutter/material.dart';

/// Barra superior fija con las acciones solicitadas para ToolMAPE.
class ToolmapeHeader extends StatelessWidget implements PreferredSizeWidget {
  const ToolmapeHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: const Text('ToolMAPE'),
      centerTitle: false,
      actions: const [
        _HeaderIcon(icon: Icons.search, tooltip: 'Buscar'),
        _HeaderIcon(icon: Icons.check_box_outline_blank, tooltip: 'Seleccionar'),
        _HeaderIcon(icon: Icons.refresh, tooltip: 'Actualizar'),
      ],
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
  });

  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: () {},
      icon: Icon(icon),
    );
  }
}
