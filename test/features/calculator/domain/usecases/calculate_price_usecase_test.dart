import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/calculator/domain/usecases/calculate_price_usecase.dart';

void main() {
  test('calculate price returns expected values', () {
    const usecase = CalculatePrice();
    const prefs = CalculatorPrefs(
      precioOro: '2000',
      tipoCambio: '3.5',
      descuento: '10',
      ley: '90',
      cantidad: '2',
    );
    final r = usecase(prefs);
    expect(r.precioPorGramo, greaterThan(0));
    expect(r.total, r.precioPorGramo * 2);
  });
}
