import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/domain/usecases/calculate_discount_from_offered_price_usecase.dart';

void main() {
  test('calculates discount from offered price', () {
    const usecase = CalculateDiscountFromOfferedPrice();
    final d = usecase(
      precioOfrecido: '300',
      precioOro: '2000',
      tipoCambio: '3.5',
      ley: '90',
    );
    expect(d, isNonNegative);
  });
}
