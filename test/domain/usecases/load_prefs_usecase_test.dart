import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/general/domain/repositories/preferencias_repository.dart';
import 'package:toolmape/features/general/domain/usecases/load_prefs_usecase.dart';

class _FakeRepo implements PreferenciasRepository {
  final CalculatorPrefs prefs;
  _FakeRepo(this.prefs);

  @override
  Future<CalculatorPrefs> load() async => prefs;

  @override
  Future<void> save(CalculatorPrefs prefs) async {}
}

void main() {
  test('load prefs retrieves stored values', () async {
    final repo = _FakeRepo(const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    ));
    final usecase = LoadPrefs(repo);
    final prefs = await usecase();
    expect(prefs.tipoCambio, '2');
  });
}
