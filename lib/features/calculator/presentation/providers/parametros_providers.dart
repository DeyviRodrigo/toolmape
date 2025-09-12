import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _goldKey = 'ultimoPrecioOro';
  static const _tcKey = 'ultimoTipoCambio';

  Future<void> _saveLocal(ParametrosRecomendados p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goldKey, p.precioOroUsdOnza);
    await prefs.setDouble(_tcKey, p.tipoCambio);
  }

  Future<ParametrosRecomendados?> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final g = prefs.getDouble(_goldKey);
    final tc = prefs.getDouble(_tcKey);
    if (g == null || tc == null) return null;
    return ParametrosRecomendados.defaults()
        .copyWith(precioOroUsdOnza: g, tipoCambio: tc);
  }

  @override
  Future<ParametrosRecomendados> build() async {
    try {
      final res = await Supabase.instance.client
          .from('stg_latest_ticks')
          .select('gold_price,pen_usd')
          .order('captured_at', ascending: false)
          .limit(1)
          .single();

      final gold = (res['gold_price'] as num?)?.toDouble() ?? 0.0;
      final penUsd = (res['pen_usd'] as num?)?.toDouble() ?? 0.0;
      final tipoCambio = penUsd;

      final data = ParametrosRecomendados.defaults().copyWith(
        precioOroUsdOnza: double.parse(gold.toStringAsFixed(2)),
        tipoCambio: double.parse(tipoCambio.toStringAsFixed(2)),
      );
      await _saveLocal(data);
      ref.read(parametrosOfflineProvider.notifier).state = false;
      return data;
    } catch (e) {
      ref.read(parametrosOfflineProvider.notifier).state = true;
      final cached = await _loadLocal();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // Métodos para actualizar desde BD o UI
  Future<void> setFromDb(ParametrosRecomendados p) async {
    state = AsyncData(p);
    await _saveLocal(p);
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

final parametrosOfflineProvider = StateProvider<bool>((_) => false);
