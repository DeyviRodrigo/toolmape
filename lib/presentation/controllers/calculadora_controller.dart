import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/calculator_prefs_entity.dart';
import '../../domain/usecases/calculate_total_usecase.dart';
import '../../domain/usecases/save_prefs_usecase.dart';
import '../../domain/usecases/load_prefs_usecase.dart';
import '../../infrastructure/datasources/preferencias_local_ds.dart';
import '../../infrastructure/repositories/preferencias_repository_impl.dart';

class CalculadoraState {
  final String precioOro;
  final String tipoCambio;
  final String descuento;
  final String ley;
  final String cantidad;
  final double? precioPorGramo;
  final double? total;
  const CalculadoraState({
    this.precioOro = '',
    this.tipoCambio = '',
    this.descuento = '',
    this.ley = '',
    this.cantidad = '',
    this.precioPorGramo,
    this.total,
  });

  CalculadoraState copyWith({
    String? precioOro,
    String? tipoCambio,
    String? descuento,
    String? ley,
    String? cantidad,
    double? precioPorGramo,
    double? total,
  }) {
    return CalculadoraState(
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

class CalculadoraController extends StateNotifier<CalculadoraState> {
  CalculadoraController({
    required CalculateTotal calcularTotal,
    required SavePrefs guardarPrefs,
    required LoadPrefs cargarPrefs,
  })  : _calcularTotal = calcularTotal,
        _guardarPrefs = guardarPrefs,
        _cargarPrefs = cargarPrefs,
        super(const CalculadoraState());

  final CalculateTotal _calcularTotal;
  final SavePrefs _guardarPrefs;
  final LoadPrefs _cargarPrefs;

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

  void setPrecioOro(String v) => state = state.copyWith(precioOro: v);
  void setTipoCambio(String v) => state = state.copyWith(tipoCambio: v);
  void setDescuento(String v) => state = state.copyWith(descuento: v);
  void setLey(String v) => state = state.copyWith(ley: v);
  void setCantidad(String v) => state = state.copyWith(cantidad: v);

  Future<void> calcular() async {
    final prefs = CalculatorPrefs(
      precioOro: state.precioOro,
      tipoCambio: state.tipoCambio,
      descuento: state.descuento,
      ley: state.ley,
      cantidad: state.cantidad,
    );
    final res = _calcularTotal(prefs);
    state = state.copyWith(precioPorGramo: res.precioPorGramo, total: res.total);
    await _guardarPrefs(prefs);
  }
}

final calculadoraControllerProvider =
    StateNotifierProvider<CalculadoraController, CalculadoraState>((ref) {
  final repo = PreferenciasRepositoryImpl(PreferenciasLocalDatasource());
  return CalculadoraController(
    calcularTotal: const CalculateTotal(),
    guardarPrefs: SavePrefs(repo),
    cargarPrefs: LoadPrefs(repo),
  );
});
