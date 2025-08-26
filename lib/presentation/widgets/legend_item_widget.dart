import 'package:flutter/material.dart';

/// Small legend item with icon and text.
class LegendItemWidget extends StatelessWidget {
  const LegendItemWidget({
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
