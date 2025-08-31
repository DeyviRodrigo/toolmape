import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/usecases/calculate_price_usecase.dart';

void main() {
  test('calculate price returns expected values', () {
    const usecase = CalculatePrice();
    final r = usecase(
      precioOro: 2000,
      tipoCambio: 3.5,
      descuento: 10,
      ley: 90,
      cantidad: 2,
    );
    expect(r.precioPorGramo, greaterThan(0));
    expect(r.total, r.precioPorGramo * 2);
  });
}
