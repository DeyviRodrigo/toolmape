import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/general/infrastructure/datasources/preferencias_local_ds.dart';
import 'package:toolmape/features/general/infrastructure/repositories/preferencias_repository_impl.dart';

class _FakePrefsDs extends PreferenciasLocalDatasource {
  CalculatorPrefs? saved;
  bool loadCalled = false;
  @override
  Future<CalculatorPrefs> load() async {
    loadCalled = true;
    return const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    );
  }

  @override
  Future<void> save(CalculatorPrefs data) async {
    saved = data;
  }
}

void main() {
  test('PreferenciasRepositoryImpl delegates to datasource', () async {
    final ds = _FakePrefsDs();
    final repo = PreferenciasRepositoryImpl(ds);
    await repo.save(const CalculatorPrefs(
      precioOro: '10',
      tipoCambio: '20',
      descuento: '5',
      ley: '90',
      cantidad: '2',
    ));
    expect(ds.saved?.precioOro, '10');
    final loaded = await repo.load();
    expect(ds.loadCalled, isTrue);
    expect(loaded.tipoCambio, '2');
  });
}
