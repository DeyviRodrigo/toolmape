class CalculadoraService {
  /// Factor para convertir onzas troy a gramos
  static const double _gramosPorOnza = 31.1034768;

  /// Calcula el precio por gramo en soles, considerando ley y descuento
  static double precioPorGramoEnSoles({
    required double precioOro,    // USD por onza
    required double tipoCambio,   // S/ por USD
    required double descuento,    // %
    required double ley,          // %
  }) {
    final precioGramoUsd = precioOro / _gramosPorOnza;
    final ajustado = precioGramoUsd * (ley / 100) * (1 - descuento / 100);
    return ajustado * tipoCambio;
  }

  /// Calcula el total en soles para la cantidad dada (en gramos)
  static double calcularTotal({
    required double precioOro,    // USD por onza
    required double tipoCambio,   // S/ por USD
    required double descuento,    // %
    required double ley,          // %
    required double cantidad,     // gramos
  }) {
    final precioUnitario = precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    return precioUnitario * cantidad;
  }
}