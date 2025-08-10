import 'package:flutter/material.dart';

class CampoNumerico extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;

  const CampoNumerico({
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
        border: const OutlineInputBorder(),
        labelText: etiqueta,
        isDense: true,
      ),
    );
  }
}