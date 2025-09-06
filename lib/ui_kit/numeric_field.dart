import 'package:flutter/material.dart';

/// Widget: NumericField - campo de texto numérico reutilizable.
class NumericField extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;

  const NumericField({
    super.key,
    required this.controller,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: etiqueta,
        isDense: true,
      ),
    );
  }
}
