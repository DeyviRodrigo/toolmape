import '../constants/constants.dart';

/// Price per gram in Peruvian soles.
double precioPorGramoEnSoles({
  required double precioOro,
  required double tipoCambio,
  required double descuento,
  required double ley,
}) {
  final precioGramoUsd = precioOro / kGramosPorOnza;
  final ajustadoUsd = precioGramoUsd * (ley / 100) * (1 - descuento / 100);
  return ajustadoUsd * tipoCambio;
}

/// Total to pay for the given [cantidad] in grams.
double calcularTotal({
  required double precioOro,
  required double tipoCambio,
  required double descuento,
  required double ley,
  required double cantidad,
}) {
  final unit = precioPorGramoEnSoles(
    precioOro: precioOro,
    tipoCambio: tipoCambio,
    descuento: descuento,
    ley: ley,
  );
  return unit * cantidad;
}

/// Base price per gram in soles without discount.
double _baseSolesPorGramo({
  required double precioOroUsdOnza,
  required double tipoCambio,
  required double leyPct,
}) {
  final usdPorGramo = precioOroUsdOnza / kGramosPorOnza;
  final usdAjustado = usdPorGramo * (leyPct / 100.0);
  return usdAjustado * tipoCambio;
}

/// Calculates discount percentage from an offered price per gram.
double descuentoDesdePrecioOfrecido({
  required double precioOfrecido,
  required double precioOroUsdOnza,
  required double tipoCambio,
  required double leyPct,
}) {
  final base = _baseSolesPorGramo(
    precioOroUsdOnza: precioOroUsdOnza,
    tipoCambio: tipoCambio,
    leyPct: leyPct,
  );
  double d = 100 * (1 - (precioOfrecido / base));
  if (d < 0) d = 0;
  if (d > 100) d = 100;
  return d;
}
