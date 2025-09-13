import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/general/data/mappers/calculator_prefs_mapper.dart';

void main() {
  test('CalculatorPrefsMapper maps between map and entity', () {
    final map = {
      'precioOro': '1',
      'tipoCambio': '2',
      'descuento': '3',
      'ley': '4',
      'cantidad': '5',
    };
    final entity = CalculatorPrefsMapper.fromMap(map);
    expect(entity.precioOro, '1');
    final back = CalculatorPrefsMapper.toMap(entity);
    expect(back, map);
  });
}
