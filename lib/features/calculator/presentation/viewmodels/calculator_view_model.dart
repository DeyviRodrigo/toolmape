import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/calculator/domain/usecases/calculate_price_usecase.dart';
import 'package:toolmape/features/general/domain/usecases/load_prefs_usecase.dart';
import 'package:toolmape/features/general/domain/usecases/save_prefs_usecase.dart';
import 'package:toolmape/app/di/di.dart';
import 'package:toolmape/core/utils/number_parsing.dart';

class CalculatorState {
  final String precioOro;
  final String tipoCambio;
  final String descuento;
  final String ley;
  final String cantidad;
  final double? precioPorGramo;
  final double? total;
  const CalculatorState({
    this.precioOro = '',
    this.tipoCambio = '',
    this.descuento = '',
    this.ley = '',
    this.cantidad = '',
    this.precioPorGramo,
    this.total,
  });

  CalculatorState copyWith({
    String? precioOro,
    String? tipoCambio,
    String? descuento,
    String? ley,
    String? cantidad,
    double? precioPorGramo,
    double? total,
  }) {
    return CalculatorState(
      precioOro: precioOro ?? this.precioOro,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      descuento: descuento ?? this.descuento,
      ley: ley ?? this.ley,
      cantidad: cantidad ?? this.cantidad,
      precioPorGramo: precioPorGramo ?? this.precioPorGramo,
      total: total ?? this.total,
    );
  }
}

class CalculatorViewModel extends StateNotifier<CalculatorState> {
  CalculatorViewModel({
    required CalculatePrice calcularPrecio,
    required SavePrefs guardarPrefs,
    required LoadPrefs cargarPrefs,
  })  : _calcularPrecio = calcularPrecio,
        _guardarPrefs = guardarPrefs,
        _cargarPrefs = cargarPrefs,
        super(const CalculatorState());

  final CalculatePrice _calcularPrecio;
  final SavePrefs _guardarPrefs;
  final LoadPrefs _cargarPrefs;

  bool _isNumeric(String v) => parseDouble(v) != null;

  Future<void> cargar() async {
    final prefs = await _cargarPrefs();
    state = state.copyWith(
      precioOro: prefs.precioOro,
      tipoCambio: prefs.tipoCambio,
      descuento: prefs.descuento,
      ley: prefs.ley,
      cantidad: prefs.cantidad,
    );
  }

  void setPrecioOro(String v) {
    if (_isNumeric(v)) state = state.copyWith(precioOro: v);
  }

  void setTipoCambio(String v) {
    if (_isNumeric(v)) state = state.copyWith(tipoCambio: v);
  }

  void setDescuento(String v) {
    if (_isNumeric(v)) state = state.copyWith(descuento: v);
  }

  void setLey(String v) {
    if (_isNumeric(v)) state = state.copyWith(ley: v);
  }

  void setCantidad(String v) {
    if (_isNumeric(v)) state = state.copyWith(cantidad: v);
  }

  Future<void> calcular() async {
    if (!_isNumeric(state.precioOro) ||
        !_isNumeric(state.tipoCambio) ||
        !_isNumeric(state.descuento) ||
        !_isNumeric(state.ley) ||
        !_isNumeric(state.cantidad)) {
      return;
    }
    final prefs = CalculatorPrefs(
      precioOro: state.precioOro,
      tipoCambio: state.tipoCambio,
      descuento: state.descuento,
      ley: state.ley,
      cantidad: state.cantidad,
    );
    final res = _calcularPrecio(prefs);
    state = state.copyWith(
      precioPorGramo: res.precioPorGramo,
      total: res.total,
    );
    await _guardarPrefs(prefs);
  }
}

typedef CalculadoraState = CalculatorState;
typedef CalculadoraViewModel = CalculatorViewModel;
typedef CalculadoraController = CalculatorViewModel;

final calculatorViewModelProvider =
    StateNotifierProvider<CalculatorViewModel, CalculatorState>((ref) {
  final repo = ref.read(preferenciasRepositoryProvider);
  return CalculatorViewModel(
    calcularPrecio: const CalculatePrice(),
    guardarPrefs: SavePrefs(repo),
    cargarPrefs: LoadPrefs(repo),
  );
});

@Deprecated('Use calculatorViewModelProvider')
final calculadoraViewModelProvider = calculatorViewModelProvider;
