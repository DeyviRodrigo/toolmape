import '../services/calculadora_formulas.dart';
import 'package:toolmape/core/utils/number_parsing.dart';
import '../entities/calculator_prefs_entity.dart';

class PriceResult {
  final double precioPorGramo;
  final double total;
  const PriceResult({required this.precioPorGramo, required this.total});
}

class CalculatePrice {
  const CalculatePrice();

  PriceResult call(CalculatorPrefs prefs) {
    final precioOro = parseDouble(prefs.precioOro) ?? 0;
    final tipoCambio = parseDouble(prefs.tipoCambio) ?? 0;
    final descuento = parseDouble(prefs.descuento) ?? 0;
    final ley = parseDouble(prefs.ley) ?? 0;
    final cantidad = parseDouble(prefs.cantidad) ?? 0;

    final precioPorGramo = precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    final total = calcularTotal(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
      cantidad: cantidad,
    );
    return PriceResult(precioPorGramo: precioPorGramo, total: total);
  }
}
