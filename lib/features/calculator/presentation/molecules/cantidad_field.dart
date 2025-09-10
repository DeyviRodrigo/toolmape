import 'package:flutter/material.dart';

import 'package:toolmape/design_system/atoms/numeric_field.dart';

class CantidadField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const CantidadField({
    super.key,
    required this.controller,
    required this.menu,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NumericField(controller: controller, etiqueta: 'Cantidad (g)'),
        ),
        menu,
      ],
    );
  }
}
