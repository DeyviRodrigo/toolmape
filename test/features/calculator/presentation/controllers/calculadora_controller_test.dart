import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/calculator/presentation/controllers/calculadora_controller.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/general/domain/repositories/preferencias_repository.dart';
import 'package:toolmape/app/init_dependencies.dart';

class _FakePrefsRepo implements PreferenciasRepository {
  CalculatorPrefs stored = const CalculatorPrefs(
    precioOro: '',
    tipoCambio: '',
    descuento: '',
    ley: '',
    cantidad: '',
  );

  @override
  Future<CalculatorPrefs> load() async => stored;

  @override
  Future<void> save(CalculatorPrefs prefs) async {
    stored = prefs;
  }
}

void main() {
  test('calcular updates state and saves prefs', () async {
    final fake = _FakePrefsRepo();
    final container = ProviderContainer(overrides: [
      preferenciasRepositoryProvider.overrideWithValue(fake),
    ]);

    final vm = container.read(calculadoraViewModelProvider.notifier);
    vm
      ..setPrecioOro('100')
      ..setTipoCambio('3')
      ..setDescuento('5')
      ..setLey('90')
      ..setCantidad('2');

    await vm.calcular();

    final state = container.read(calculadoraViewModelProvider);
    expect(state.total, isNotNull);
    expect(fake.stored.precioOro, '100');
  });
}
