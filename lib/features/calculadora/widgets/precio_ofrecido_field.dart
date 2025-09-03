import 'package:flutter/material.dart';

import '../../../ui_kit/numeric_field.dart';

class PrecioOfrecidoField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const PrecioOfrecidoField({
    super.key,
    required this.controller,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NumericField(
            controller: controller,
            etiqueta: 'Precio (S/)',
          ),
        ),
        menu,
      ],
    );
  }
}
