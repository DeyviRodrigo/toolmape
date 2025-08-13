import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import 'calculadora_options.dart';
import '../../services/calculadora_service.dart';

/// Clase: ResultadoCalculo - resultado del cálculo por gramo y total.
class ResultadoCalculo {
  final double precioPorGramo;
  final double total;
  const ResultadoCalculo({required this.precioPorGramo, required this.total});
}

/// Clase: CalculadoraController - maneja la lógica de la calculadora.
class CalculadoraController {
  // Persistencia
  /// Función: cargarPreferenciasInto - carga valores desde almacenamiento local.
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

  /// Función: guardarPreferenciasFrom - guarda valores en almacenamiento local.
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

  // Acción general “Actualizar” usa sugeridos que le pasa la pantalla
  /// Función: onGeneralAction - gestiona las acciones generales del menú.
  bool onGeneralAction(
      GeneralAction a,
      TextEditingController target, {
        required double precioOroSugerido,
        required double tipoCambioSugerido,
        required TextEditingController precioOroCtrl,
        required TextEditingController tipoCambioCtrl,
      }) {
    switch (a) {
      case GeneralAction.actualizar:
        if (target == precioOroCtrl) target.text = precioOroSugerido.toString();
        if (target == tipoCambioCtrl) target.text = tipoCambioSugerido.toString();
        return true;
      case GeneralAction.avanzadas:
      case GeneralAction.personalizados:
        return false;
    }
  }

  /// Función: calcular - realiza el cálculo principal.
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

  // Base S/ por gramo sin descuento
  /// Función: baseSolesPorGramo - calcula base sin aplicar descuento.
  double baseSolesPorGramo({
    required double precioOroUsdOnza,
    required double tipoCambio,
    required double leyPct,
  }) {
    final usdPorGramo = precioOroUsdOnza / kGramosPorOnza;
    final usdAjustado = usdPorGramo * (leyPct / 100.0);
    return usdAjustado * tipoCambio;
  }
}
