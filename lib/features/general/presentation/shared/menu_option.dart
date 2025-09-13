import 'package:flutter/material.dart';

class MenuOption<T> {
  final T value;
  final String label;
  final IconData icon;
  const MenuOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}
