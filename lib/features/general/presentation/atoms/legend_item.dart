import 'package:flutter/material.dart';

/// Atom: LegendItem - icon and label for legends.
class LegendItem extends StatelessWidget {
  const LegendItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
