import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/domain/usecases/calculate_price_usecase.dart';
import 'package:toolmape/domain/usecases/load_prefs_usecase.dart';
import 'package:toolmape/domain/usecases/save_prefs_usecase.dart';
import 'package:toolmape/presentation/controllers/calculadora_controller.dart';

class _FakeCalc extends CalculatePrice {
  Map<String, double>? params;
  const _FakeCalc();
  @override
  PriceResult call({
    required double precioOro,
    required double tipoCambio,
    required double descuento,
    required double ley,
    required double cantidad,
  }) {
    params = {
      'precioOro': precioOro,
      'tipoCambio': tipoCambio,
      'descuento': descuento,
      'ley': ley,
      'cantidad': cantidad,
    };
    return const PriceResult(precioPorGramo: 1, total: 2);
  }
}

void main() {
  test('controller delegates to use cases', () async {
    final calc = const _FakeCalc();
    final stored = <String, String>{};
    final save = SavePrefs(setString: (k, v) async {
      stored[k] = v;
    });
    final loadData = {
      'precioOro': '1',
      'tipoCambio': '2',
      'descuento': '3',
      'ley': '4',
      'cantidad': '5',
    };
    final load = LoadPrefs(getString: (k) async => loadData[k]);

    final controller = CalculadoraController(
      calcularPrecio: calc,
      guardarPrefs: save,
      cargarPrefs: load,
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

    expect(calc.params!['precioOro'], 10);
    expect(stored['precioOro'], '10');
    expect(controller.state.total, 2);
  });
}
