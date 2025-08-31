import 'package:flutter/material.dart';

import '../../../widgets/campo_numerico.dart';

class LeyField extends StatelessWidget {
  final TextEditingController controller;
  final Widget menu;
  const LeyField({super.key, required this.controller, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CampoNumerico(
            controller: controller,
            etiqueta: 'Ley (%)',
          ),
        ),
        menu,
      ],
    );
  }
}
