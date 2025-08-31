import '../../services/calculadora_service.dart';

class PriceResult {
  final double precioPorGramo;
  final double total;
  const PriceResult({required this.precioPorGramo, required this.total});
}

class CalculatePrice {
  const CalculatePrice();

  PriceResult call({
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
    return PriceResult(precioPorGramo: precioPorGramo, total: total);
  }
}
