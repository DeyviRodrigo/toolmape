import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/general/domain/repositories/preferencias_repository.dart';
import 'package:toolmape/features/general/domain/usecases/save_prefs_usecase.dart';

class _FakeRepo implements PreferenciasRepository {
  CalculatorPrefs? saved;
  @override
  Future<CalculatorPrefs> load() async => const CalculatorPrefs(
        precioOro: '',
        tipoCambio: '',
        descuento: '',
        ley: '',
        cantidad: '',
      );

  @override
  Future<void> save(CalculatorPrefs prefs) async {
    saved = prefs;
  }
}

void main() {
  test('save prefs delegates to repository', () async {
    final repo = _FakeRepo();
    final usecase = SavePrefs(repo);
    await usecase(const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    ));
    expect(repo.saved?.precioOro, '1');
  });
}
