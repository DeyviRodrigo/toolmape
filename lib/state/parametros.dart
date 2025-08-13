import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Clase: ParametrosRecomendados - modelo con valores recomendados.
class ParametrosRecomendados {
  final double precioOroUsdOnza;
  final double tipoCambio;
  final double descuentoSugerido;
  final double leySugerida;

  const ParametrosRecomendados({
    required this.precioOroUsdOnza,
    required this.tipoCambio,
    required this.descuentoSugerido,
    required this.leySugerida,
  });

  factory ParametrosRecomendados.defaults() => const ParametrosRecomendados(
    precioOroUsdOnza: 3394.90,
    tipoCambio: 3.56,
    descuentoSugerido: 7,
    leySugerida: 93,
  );

  ParametrosRecomendados copyWith({
    double? precioOroUsdOnza,
    double? tipoCambio,
    double? descuentoSugerido,
    double? leySugerida,
  }) {
    return ParametrosRecomendados(
      precioOroUsdOnza: precioOroUsdOnza ?? this.precioOroUsdOnza,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      descuentoSugerido: descuentoSugerido ?? this.descuentoSugerido,
      leySugerida: leySugerida ?? this.leySugerida,
    );
  }
}

/// Notifier: ParametrosNotifier - gestiona los parámetros recomendados.
class ParametrosNotifier extends AsyncNotifier<ParametrosRecomendados> {
  @override
  Future<ParametrosRecomendados> build() async {
    // TODO: aquí luego lees de Supabase / BD y devuelves esos valores
    // fallback a defaults
    return ParametrosRecomendados.defaults();
  }

  // Métodos para actualizar desde BD o UI
  Future<void> setFromDb(ParametrosRecomendados p) async {
    state = AsyncData(p);
  }

  void setPrecioOro(double v) =>
      state = AsyncData((state.value ?? ParametrosRecomendados.defaults()).copyWith(precioOroUsdOnza: v));
  void setTipoCambio(double v) =>
      state = AsyncData((state.value ?? ParametrosRecomendados.defaults()).copyWith(tipoCambio: v));
  void setDescuento(double v) =>
      state = AsyncData((state.value ?? ParametrosRecomendados.defaults()).copyWith(descuentoSugerido: v));
  void setLey(double v) =>
      state = AsyncData((state.value ?? ParametrosRecomendados.defaults()).copyWith(leySugerida: v));
}

/// Provider: parametrosProvider - expone ParametrosNotifier.
final parametrosProvider = AsyncNotifierProvider<ParametrosNotifier, ParametrosRecomendados>(
      () => ParametrosNotifier(),
);
