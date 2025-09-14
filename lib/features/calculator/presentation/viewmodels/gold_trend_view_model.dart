import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TrendRange { diario, semanal, mensual, anual }

class GoldTrendPoint {
  final DateTime time;
  final double price;
  const GoldTrendPoint(this.time, this.price);
}

class GoldTrendState {
  final TrendRange range;
  final String currency;
  final List<GoldTrendPoint> points;
  final double? bid;
  final double? ask;
  final double? changeAbs;
  final double? changePct;
  const GoldTrendState({
    required this.range,
    required this.currency,
    required this.points,
    this.bid,
    this.ask,
    this.changeAbs,
    this.changePct,
  });

  DateTime? get from => points.isEmpty ? null : points.first.time;
  DateTime? get to => points.isEmpty ? null : points.last.time;
}

class GoldTrendViewModel extends AsyncNotifier<GoldTrendState> {
  TrendRange _range = TrendRange.diario;
  String _currency = 'USD';

  @override
  Future<GoldTrendState> build() => _load();

  Future<void> setRange(TrendRange r) async {
    _range = r;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> setCurrency(String c) async {
    _currency = c;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<GoldTrendState> _load() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final pts = <GoldTrendPoint>[];
    if (_range == TrendRange.diario || _range == TrendRange.semanal) {
      final start = _range == TrendRange.diario
          ? DateTime(now.year, now.month, now.day)
          : now.subtract(const Duration(days: 7));
      final query = client
          .from('stg_latest_ticks')
          .select('captured_at, gold_price, pen_usd')
          .gte('captured_at', start.toIso8601String())
          .order('captured_at', ascending: true);
      final rows = _range == TrendRange.diario
          ? await query.lt(
              'captured_at',
              start.add(const Duration(days: 1)).toIso8601String(),
            )
          : await query;
      for (final r in rows) {
        final ts = DateTime.tryParse('${r['captured_at']}')?.toLocal();
        final gold = (r['gold_price'] as num?)?.toDouble();
        final rate = (r['pen_usd'] as num?)?.toDouble();
        if (ts == null || gold == null) continue;
        final price =
            _currency == 'USD' ? gold : (rate == null ? null : gold * rate);
        if (price != null) pts.add(GoldTrendPoint(ts, price));
      }
    } else {
      final days = _range == TrendRange.mensual ? 30 : 365;
      final start = now.subtract(Duration(days: days));
      final rows = await client
          .from('fact_daily_summary')
          .select('date_lima, avg_gold_spot_price, avg_pen_usd')
          .gte('date_lima', start.toIso8601String().split('T').first)
          .order('date_lima', ascending: true);
      for (final r in rows) {
        final ts = DateTime.tryParse('${r['date_lima']}')?.toLocal();
        final gold = (r['avg_gold_spot_price'] as num?)?.toDouble();
        final rate = (r['avg_pen_usd'] as num?)?.toDouble();
        if (ts == null || gold == null) continue;
        final price =
            _currency == 'USD' ? gold : (rate == null ? null : gold * rate);
        if (price != null) pts.add(GoldTrendPoint(ts, price));
      }
    }

    pts.sort((a, b) => a.time.compareTo(b.time));

    final spot = await client
        .from('stg_spot_ticks')
        .select('ask, bid, change_abs, change_pct')
        .filter('metal_code', 'in', '("XAU","xau","GOLD","Gold","gold")')
        .ilike('currency', 'usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final penRow = await client
        .from('stg_latest_ticks')
        .select('pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final rate = (penRow?['pen_usd'] as num?)?.toDouble();

    final bidUsd = (spot?['bid'] as num?)?.toDouble();
    final askUsd = (spot?['ask'] as num?)?.toDouble();
    final changeAbs = (spot?['change_abs'] as num?)?.toDouble();
    final changePct = (spot?['change_pct'] as num?)?.toDouble();

    double? bid = bidUsd;
    double? ask = askUsd;
    if (_currency == 'PEN' && rate != null) {
      bid = bidUsd == null ? null : bidUsd * rate;
      ask = askUsd == null ? null : askUsd * rate;
    }

    return GoldTrendState(
      range: _range,
      currency: _currency,
      points: pts,
      bid: bid,
      ask: ask,
      changeAbs: changeAbs,
      changePct: changePct,
    );
  }
}

final goldTrendViewModelProvider =
    AsyncNotifierProvider<GoldTrendViewModel, GoldTrendState>(
  () => GoldTrendViewModel(),
);
