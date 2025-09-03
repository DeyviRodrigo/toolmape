import 'package:flutter/material.dart';

import 'menu_option.dart';

const Offset menuOffsetUp = Offset(0, -36);

PopupMenuButton<T> buildMenu<T>({
  required IconData icon,
  required List<MenuOption<T>> options,
  required void Function(T) onSelected,
  Offset offset = menuOffsetUp,
}) {
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
                Text(o.label),
              ],
            ),
          ),
        )
        .toList(),
    onSelected: onSelected,
  );
}

