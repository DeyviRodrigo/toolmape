import 'package:flutter/material.dart';

class CampoNumerico extends StatelessWidget {
  final TextEditingController controller;
  final String etiqueta;

  const CampoNumerico({
    Key? key,
    required this.controller,
    required this.etiqueta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: etiqueta,
      ),
    );
  }
}