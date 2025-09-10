import 'package:flutter/material.dart';

import 'package:toolmape/design_system/atoms/numeric_field.dart';

class LeyField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const LeyField({super.key, required this.controller, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NumericField(controller: controller, etiqueta: 'Ley (%)'),
        ),
        menu,
      ],
    );
  }
}
