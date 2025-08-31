import '../../services/calculadora_service.dart';
import '../entities/calculator_prefs_entity.dart';

class PriceResult {
  final double precioPorGramo;
  final double total;
  const PriceResult({required this.precioPorGramo, required this.total});
}

class CalculateTotal {
  const CalculateTotal();

  PriceResult call(CalculatorPrefs prefs) {
    double parse(String s) => double.parse(s.replaceAll(',', '.'));
    final precioOro = parse(prefs.precioOro);
    final tipoCambio = parse(prefs.tipoCambio);
    final descuento = parse(prefs.descuento);
    final ley = parse(prefs.ley);
    final cantidad = parse(prefs.cantidad);

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
    return PriceResult(precioPorGramo: precioPorGramo, total: total);
  }
}
