import '../services/calculadora_formulas.dart';
import 'package:toolmape/core/utils/number_parsing.dart';

class CalculateDiscountFromOfferedPrice {
  const CalculateDiscountFromOfferedPrice();

  double call({
    required String precioOfrecido,
    required String precioOro,
    required String tipoCambio,
    required String ley,
  }) {
    final ofrecido = parseDouble(precioOfrecido) ?? 0;
    final oro = parseDouble(precioOro) ?? 0;
    final tc = parseDouble(tipoCambio) ?? 0;
    final l = parseDouble(ley) ?? 0;

    return descuentoDesdePrecioOfrecido(
      precioOfrecido: ofrecido,
      precioOroUsdOnza: oro,
      tipoCambio: tc,
      leyPct: l,
    );
  }
}
