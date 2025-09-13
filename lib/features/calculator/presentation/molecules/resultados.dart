import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../controllers/calculadora_controller.dart';

class Resultados extends StatelessWidget {
  const Resultados({super.key, required this.state});
  final CalculadoraState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.precioPorGramo != null)
          Text(
            'Precio por gramo: ${soles(state.precioPorGramo!)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (state.total != null)
          Text(
            'Precio total: ${soles(state.total!)}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
