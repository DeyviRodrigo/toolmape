class CalculadoraService {
  static const double _gramosPorOnza = 31.1034768;

  static double precioPorGramoEnSoles({
    required double precioOro,   // USD/onza
    required double tipoCambio,  // S/ por USD
    required double descuento,   // %
    required double ley,         // %
  }) {
    final precioGramoUsd = precioOro / _gramosPorOnza;
    final ajustadoUsd = precioGramoUsd * (ley / 100) * (1 - descuento / 100);
    return ajustadoUsd * tipoCambio;
  }

  static double calcularTotal({
    required double precioOro,
    required double tipoCambio,
    required double descuento,
    required double ley,
    required double cantidad, // gramos
  }) {
    final unit = precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    return unit * cantidad;
  }
}