import 'package:flutter/material.dart';

import 'package:toolmape/features/general/presentation/atoms/numeric_field.dart';

class PrecioOroField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const PrecioOroField({
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
            etiqueta: 'Precio oro (USD/onza)',
          ),
        ),
        menu,
      ],
    );
  }
}
