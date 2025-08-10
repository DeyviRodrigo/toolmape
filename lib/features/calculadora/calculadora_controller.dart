import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculadora_constants.dart';
import 'calculadora_options.dart';
import '../../core/utils/dialogs.dart';
import '../../services/calculadora_service.dart';

class ResultadoCalculo {
  final double precioPorGramo;
  final double total;
  const ResultadoCalculo({required this.precioPorGramo, required this.total});
}

class CalculadoraController {
  // -------- Persistencia --------
  Future<void> cargarPreferenciasInto({
    required TextEditingController precioOro,
    required TextEditingController tipoCambio,
    required TextEditingController descuento,
    required TextEditingController ley,
    required TextEditingController cantidad,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    precioOro.text = prefs.getString('precioOro') ?? '';
    tipoCambio.text = prefs.getString('tipoCambio') ?? '';
    descuento.text  = prefs.getString('descuento') ?? '';
    ley.text        = prefs.getString('ley') ?? '';
    cantidad.text   = prefs.getString('cantidad') ?? '';
  }

  Future<void> guardarPreferenciasFrom({
    required TextEditingController precioOro,
    required TextEditingController tipoCambio,
    required TextEditingController descuento,
    required TextEditingController ley,
    required TextEditingController cantidad,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('precioOro', precioOro.text);
    await prefs.setString('tipoCambio', tipoCambio.text);
    await prefs.setString('descuento', descuento.text);
    await prefs.setString('ley', ley.text);
    await prefs.setString('cantidad', cantidad.text);
  }

  // -------- Defaults --------
  void ensureDefaultsIfEmpty({
    required TextEditingController precioOro,
    required TextEditingController tipoCambio,
    required TextEditingController descuento,
    required TextEditingController ley,
    required TextEditingController cantidad,
  }) {
    if (precioOro.text.trim().isEmpty) precioOro.text = kPrecioOroDefault.toString();
    if (tipoCambio.text.trim().isEmpty) tipoCambio.text = kTipoCambioDefault.toString();
    if (descuento.text.trim().isEmpty)  descuento.text  = kDescuentoDefault.toString();
    if (ley.text.trim().isEmpty)        ley.text        = kLeyDefault.toString();
    if (cantidad.text.trim().isEmpty)   cantidad.text   = '1';
  }

  // -------- Menú General (precio / tipo de cambio) --------
  bool onGeneralAction(
      GeneralAction a,
      TextEditingController target, {
        required TextEditingController precioOro,
        required TextEditingController tipoCambio,
      }) {
    switch (a) {
      case GeneralAction.actualizar:
        if (target == precioOro) target.text = kPrecioOroDefault.toString();
        if (target == tipoCambio) target.text = kTipoCambioDefault.toString();
        return true;
      case GeneralAction.avanzadas:
        return false; // TODO: navegar a pantalla avanzada
      case GeneralAction.personalizados:
        return false; // TODO: abrir modal/manual
    }
  }

  // -------- Cálculo principal --------
  ResultadoCalculo calcular({
    required double precioOro,
    required double tipoCambio,
    required double descuento,
    required double ley,
    required double cantidad,
  }) {
    final precioPorGramo = CalculadoraService.precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    final total = CalculadoraService.calcularTotal(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
      cantidad: cantidad,
    );
    return ResultadoCalculo(precioPorGramo: precioPorGramo, total: total);
  }

  // -------- Ayuda: calcular descuento desde precio ofrecido + ley --------
  Future<bool> dialogoCalcularDescuentoConLey({
    required BuildContext context,
    required List<MenuOption<LeyAction>> leyMenuOptions,
    required TextEditingController descuentoCtrl,
    required TextEditingController leyCtrl,
    required TextEditingController precioOroCtrl,
    required TextEditingController tipoCambioCtrl,
  }) async {
    if (precioOroCtrl.text.trim().isEmpty) precioOroCtrl.text = kPrecioOroDefault.toString();
    if (tipoCambioCtrl.text.trim().isEmpty) tipoCambioCtrl.text = kTipoCambioDefault.toString();

    while (true) {
      final precioOfrecidoCtrl = TextEditingController();
      final leyInputCtrl = TextEditingController(
        text: leyCtrl.text.isNotEmpty ? leyCtrl.text : kLeyDefault.toString(),
      );

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
                          switch (act) {
                            case LeyAction.ayuda:
                            // TODO: Navegar a flujo de ayuda de ley
                              break;
                            case LeyAction.predeterminado:
                              leyInputCtrl.text = kLeyDefault.toString();
                              setLocal(() {});
                              break;
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

      final ofrecido = double.tryParse(precioOfrecidoCtrl.text.replaceAll(',', '.'));
      final leyUsada = double.tryParse(leyInputCtrl.text.replaceAll(',', '.')) ?? kLeyDefault;
      if (ofrecido == null || ofrecido <= 0) return false;

      final precioOro = double.parse(precioOroCtrl.text.replaceAll(',', '.'));
      final tc = double.parse(tipoCambioCtrl.text.replaceAll(',', '.'));

      final base = _baseSolesPorGramo(
        precioOroUsdOnza: precioOro,
        tipoCambio: tc,
        leyPct: leyUsada,
      );

      double d = 100 * (1 - (ofrecido / base));
      if (d < 0) d = 0;
      if (d > 100) d = 100;

      final next = await _dialogoResultadoDescuento(context, d);
      if (next == 'recalcular') {
        continue; // reabre
      } else {
        descuentoCtrl.text = d.toStringAsFixed(2);
        leyCtrl.text = leyUsada.toStringAsFixed(2);
        return true; // aplicado
      }
    }
  }

  Future<String?> _dialogoResultadoDescuento(BuildContext context, double d) {
    return showDialog<String>(
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
  }

  // Base en S/ por gramo sin descuento (ley y TC aplicados)
  double _baseSolesPorGramo({
    required double precioOroUsdOnza,
    required double tipoCambio,
    required double leyPct,
  }) {
    final usdPorGramo = precioOroUsdOnza / kGramosPorOnza;
    final usdAjustado = usdPorGramo * (leyPct / 100.0);
    return usdAjustado * tipoCambio;
  }
}