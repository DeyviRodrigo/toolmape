import 'package:flutter/material.dart';

import '../../../ui_kit/numeric_field.dart';

class TipoCambioField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const TipoCambioField({
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
            etiqueta: 'Tipo de cambio (S/ por USD)',
          ),
        ),
        menu,
      ],
    );
  }
}
