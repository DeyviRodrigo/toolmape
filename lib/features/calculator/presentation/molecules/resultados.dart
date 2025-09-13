import 'package:flutter/material.dart';

import 'package:toolmape/core/utils/formatters.dart';
import '../viewmodels/calculator_view_model.dart';

class Resultados extends StatelessWidget {
  const Resultados({super.key, required this.state});
  final CalculatorState state;

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
