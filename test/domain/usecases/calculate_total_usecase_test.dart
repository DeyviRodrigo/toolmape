import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/domain/usecases/calculate_total_usecase.dart';

void main() {
  test('calculate total returns expected values', () {
    const usecase = CalculateTotal();
    final prefs = const CalculatorPrefs(
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
