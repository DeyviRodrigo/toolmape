import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/calculate_discount_from_offered_price_usecase.dart';
import '../../core/utils/number_parsing.dart';

class DescuentoState {
  final String precioOro;
  final String tipoCambio;
  final String ley;
  final String precio;
  final double? descuento;
  const DescuentoState({
    this.precioOro = '',
    this.tipoCambio = '',
    this.ley = '',
    this.precio = '',
    this.descuento,
  });

  DescuentoState copyWith({
    String? precioOro,
    String? tipoCambio,
    String? ley,
    String? precio,
    double? descuento,
  }) {
    return DescuentoState(
      precioOro: precioOro ?? this.precioOro,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      ley: ley ?? this.ley,
      precio: precio ?? this.precio,
      descuento: descuento ?? this.descuento,
    );
  }
}

class DescuentoViewModel extends StateNotifier<DescuentoState> {
  DescuentoViewModel(this._calcular) : super(const DescuentoState());

  final CalculateDiscountFromOfferedPrice _calcular;

  bool _isNumeric(String v) => parseDouble(v) != null;

  void setPrecioOro(String v) {
    if (_isNumeric(v)) state = state.copyWith(precioOro: v);
  }

  void setTipoCambio(String v) {
    if (_isNumeric(v)) state = state.copyWith(tipoCambio: v);
  }

  void setLey(String v) {
    if (_isNumeric(v)) state = state.copyWith(ley: v);
  }

  void setPrecio(String v) {
    if (_isNumeric(v)) state = state.copyWith(precio: v);
  }

  Future<void> calcular() async {
    if (!_isNumeric(state.precioOro) ||
        !_isNumeric(state.tipoCambio) ||
        !_isNumeric(state.ley) ||
        !_isNumeric(state.precio)) {
      return;
    }
    final d = _calcular(
      precioOfrecido: state.precio,
      precioOro: state.precioOro,
      tipoCambio: state.tipoCambio,
      ley: state.ley,
    );
    state = state.copyWith(descuento: d);
  }
}

final descuentoViewModelProvider =
    StateNotifierProvider<DescuentoViewModel, DescuentoState>((ref) {
  return DescuentoViewModel(const CalculateDiscountFromOfferedPrice());
});

