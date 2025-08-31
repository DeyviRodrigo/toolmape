import 'package:flutter/material.dart';

import '../../../widgets/campo_numerico.dart';

class CantidadField extends StatelessWidget {
  final TextEditingController controller;
  const CantidadField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CampoNumerico(
      controller: controller,
      etiqueta: 'Cantidad (g)',
    );
  }
}
