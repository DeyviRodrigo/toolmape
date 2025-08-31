import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/usecases/load_prefs_usecase.dart';

void main() {
  test('load prefs retrieves stored values', () async {
    final data = {
      'precioOro': '1',
      'tipoCambio': '2',
      'descuento': '3',
      'ley': '4',
      'cantidad': '5',
    };
    final usecase = LoadPrefs(getString: (k) async => data[k]);
    final prefs = await usecase();
    expect(prefs.tipoCambio, '2');
  });
}
