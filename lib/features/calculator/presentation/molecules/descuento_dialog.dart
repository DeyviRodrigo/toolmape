import 'package:flutter/material.dart';

import 'package:toolmape/core/utils/number_parsing.dart';
import 'package:toolmape/features/calculator/domain/usecases/calculate_discount_from_offered_price_usecase.dart';
import 'package:toolmape/features/calculator/options/index.dart';
import 'package:toolmape/features/calculator/presentation/providers/parametros_providers.dart';

/// Dialog helper to calculate discount based on offered price and gold law.
Future<bool> showDescuentoDialog({
  required BuildContext context,
  required TextEditingController precioOroCtrl,
  required TextEditingController tipoCambioCtrl,
  required TextEditingController descuentoCtrl,
  required TextEditingController leyCtrl,
  required ParametrosRecomendados sugeridos,
}) async {
  final precioOfrecidoCtrl = TextEditingController();
  final leyInputCtrl = TextEditingController(
    text: leyCtrl.text.isNotEmpty ? leyCtrl.text : sugeridos.leySugerida.toString(),
  );

  final calcDiscount = const CalculateDiscountFromOfferedPrice();

  while (true) {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('Calcular descuento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Precio ofrecido por gramo (S/):'),
                const SizedBox(height: 8),
                TextField(
                  controller: precioOfrecidoCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Ej: 300.00',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Ley (%)'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: leyInputCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 93',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<LeyAction>(
                      icon: const Icon(Icons.help_outline),
                      offset: const Offset(0, -12),
                      itemBuilder: (_) => leyMenuOptions
                          .map((o) => PopupMenuItem<LeyAction>(
                                value: o.value,
                                child: Row(children: [
                                  Icon(o.icon, size: 18),
                                  const SizedBox(width: 8),
                                  Text(o.label),
                                ]),
                              ))
                          .toList(),
                      onSelected: (act) {
                        if (act == LeyAction.predeterminado) {
                          leyInputCtrl.text = sugeridos.leySugerida.toString();
                          setLocal(() {});
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Calcular')),
            ],
          );
        },
      ),
    );

    if (ok != true) return false;

    final ofrecido = parseDouble(precioOfrecidoCtrl.text);
    if (ofrecido == null || ofrecido <= 0) return false;

    final leyStr = leyInputCtrl.text.isNotEmpty
        ? leyInputCtrl.text
        : sugeridos.leySugerida.toString();
    final d = calcDiscount(
      precioOfrecido: precioOfrecidoCtrl.text,
      precioOro: precioOroCtrl.text.isNotEmpty
          ? precioOroCtrl.text
          : sugeridos.precioOroUsdOnza.toString(),
      tipoCambio: tipoCambioCtrl.text.isNotEmpty
          ? tipoCambioCtrl.text
          : sugeridos.tipoCambio.toString(),
      ley: leyStr,
    );
    final leyUsada = parseDouble(leyStr) ?? sugeridos.leySugerida;

    final next = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Resultado'),
        content: Text('El descuento aplicado es ${d.toStringAsFixed(2)}%'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'recalcular'), child: const Text('Recalcular')),
          FilledButton(onPressed: () => Navigator.pop(context, 'continuar'), child: const Text('Continuar')),
        ],
      ),
    );

    if (next == 'recalcular') {
      continue;
    } else {
      descuentoCtrl.text = d.toStringAsFixed(2);
      leyCtrl.text = leyUsada.toStringAsFixed(2);
      return true;
    }
  }
}
