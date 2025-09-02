import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        precioOroUsdOnza: 0,
        tipoCambio: 0,
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
    final res = await Supabase.instance.client
        .from('stg_latest_ticks')
        .select('gold_price,pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .single();

    final gold = (res['gold_price'] as num?)?.toDouble() ?? 0.0;
    final penUsd = (res['pen_usd'] as num?)?.toDouble() ?? 0.0;
    final tipoCambio = penUsd == 0.0 ? 0.0 : 1 / penUsd;

    return ParametrosRecomendados.defaults()
        .copyWith(precioOroUsdOnza: gold, tipoCambio: tipoCambio);
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
