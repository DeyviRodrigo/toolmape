import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/domain/usecases/save_prefs_usecase.dart';

void main() {
  test('save prefs stores all fields', () async {
    final stored = <String, String>{};
    final usecase = SavePrefs(setString: (k, v) async {
      stored[k] = v;
    });
    await usecase(const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    ));
    expect(stored['precioOro'], '1');
    expect(stored.length, 5);
  });
}
