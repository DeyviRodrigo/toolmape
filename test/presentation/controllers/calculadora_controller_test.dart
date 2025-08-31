import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/domain/repositories/preferencias_repository.dart';
import 'package:toolmape/domain/usecases/calculate_total_usecase.dart';
import 'package:toolmape/domain/usecases/load_prefs_usecase.dart';
import 'package:toolmape/domain/usecases/save_prefs_usecase.dart';
import 'package:toolmape/presentation/controllers/calculadora_controller.dart';

class _FakeCalc extends CalculateTotal {
  CalculatorPrefs? params;
  const _FakeCalc();
  @override
  PriceResult call(CalculatorPrefs prefs) {
    params = prefs;
    return const PriceResult(precioPorGramo: 1, total: 2);
  }
}

class _FakeRepo implements PreferenciasRepository {
  CalculatorPrefs? saved;
  CalculatorPrefs loadValue;
  _FakeRepo(this.loadValue);

  @override
  Future<CalculatorPrefs> load() async => loadValue;

  @override
  Future<void> save(CalculatorPrefs prefs) async {
    saved = prefs;
  }
}

void main() {
  test('controller delegates to use cases', () async {
    final repo = _FakeRepo(const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    ));
    final calc = const _FakeCalc();
    final controller = CalculadoraController(
      calcularTotal: calc,
      guardarPrefs: SavePrefs(repo),
      cargarPrefs: LoadPrefs(repo),
    );

    await controller.cargar();
    expect(controller.state.precioOro, '1');

    controller
      ..setPrecioOro('10')
      ..setTipoCambio('20')
      ..setDescuento('5')
      ..setLey('90')
      ..setCantidad('2');
    await controller.calcular();

    expect(calc.params!.precioOro, '10');
    expect(repo.saved!.precioOro, '10');
    expect(controller.state.total, 2);
  });
}
