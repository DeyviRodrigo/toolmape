import 'package:flutter/material.dart';
import '../atoms/menu_option.dart';

class MenuPopupButton<T> extends StatelessWidget {
  const MenuPopupButton({
    super.key,
    required this.icon,
    required this.options,
    required this.onSelected,
    this.offset = const Offset(0, -36),
  });

  final IconData icon;
  final List<MenuOption<T>> options;
  final void Function(T) onSelected;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      icon: Icon(icon),
      offset: offset,
      itemBuilder: (_) => options
          .map(
            (o) => PopupMenuItem<T>(
              value: o.value,
              child: Row(
                children: [
                  Icon(o.icon, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      o.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onSelected: onSelected,
    );
  }
}
