import 'package:flutter/material.dart';

class ResultPanel extends StatelessWidget {
  final double? precioPorGramo;
  final double? total;
  const ResultPanel({super.key, this.precioPorGramo, this.total});

  @override
  Widget build(BuildContext context) {
    if (precioPorGramo == null || total == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Precio por gramo: S/ ${precioPorGramo!.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        Text('Total: S/ ${total!.toStringAsFixed(2)}'),
      ],
    );
  }
}
