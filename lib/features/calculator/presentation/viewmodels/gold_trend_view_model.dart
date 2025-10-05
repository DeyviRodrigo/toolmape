import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum TrendRange { diario, semanal, mensual, anual, general }

enum GoldUnit { toz, gram, kilogram }

class GoldTrendPoint {
  final DateTime time;
  final double price;
  const GoldTrendPoint(this.time, this.price);
}

class GoldTrendState {
  final TrendRange range;
  final String currency;
  final GoldUnit unit;
  final List<GoldTrendPoint> points;
  final double? bid;
  final double? ask;
  final double? changeAbs;
  final double? changePct;
  const GoldTrendState({
    required this.range,
    required this.currency,
    required this.unit,
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
  GoldUnit _unit = GoldUnit.toz;

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

  Future<void> setUnit(GoldUnit unit) async {
    _unit = unit;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  double _unitFactor(GoldUnit unit) {
    const gramsPerTroyOunce = 31.1034768;
    switch (unit) {
      case GoldUnit.toz:
        return 1.0;
      case GoldUnit.gram:
        return 1 / gramsPerTroyOunce;
      case GoldUnit.kilogram:
        return 1000 / gramsPerTroyOunce;
    }
  }

  Future<GoldTrendState> _load() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final rateRow = await client
        .from('stg_latest_ticks')
        .select('pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final latestRate = (rateRow?['pen_usd'] as num?)?.toDouble();

    Future<List<GoldTrendPoint>> loadCombinedTicks({
      required DateTime start,
      DateTime? end,
    }) async {
      var query = client
          .from('gold_price_combined_v')
          .select('captured_at, gold_price')
          .gte('captured_at', start.toUtc().toIso8601String());

      if (end != null) {
        query = query.lt('captured_at', end.toUtc().toIso8601String());
      }

      final rows = await query.order('captured_at', ascending: true);
      final dedup = <String, GoldTrendPoint>{};

      for (final r in rows) {
        final ts = DateTime.tryParse('${r['captured_at']}')?.toLocal();
        final gold = (r['gold_price'] as num?)?.toDouble();
        if (ts == null || gold == null) continue;
        dedup[ts.toIso8601String()] = GoldTrendPoint(ts, gold);
      }

      final pts = dedup.values.toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      return pts;
    }

    Future<List<GoldTrendPoint>> loadLatestTicks({
      required DateTime start,
      DateTime? end,
    }) async {
      var query = client
          .from('stg_latest_ticks')
          .select('captured_at, gold_price, pen_usd')
          .gte('captured_at', start.toUtc().toIso8601String());

      if (end != null) {
        query = query.lt('captured_at', end.toUtc().toIso8601String());
      }

      final rows = await query.order('captured_at', ascending: true);
      final pts = <GoldTrendPoint>[];
      for (final r in rows) {
        final ts = DateTime.tryParse('${r['captured_at']}')?.toLocal();
        final gold = (r['gold_price'] as num?)?.toDouble();
        final rate = (r['pen_usd'] as num?)?.toDouble();
        if (ts == null || gold == null || rate == null) continue;
        pts.add(GoldTrendPoint(ts, gold * rate));
      }
      return pts;
    }

    Future<List<GoldTrendPoint>> loadDailySummary({DateTime? start}) async {
      var query = client.from('fact_daily_summary').select(
          'date_lima, avg_gold_usd_combined, avg_gold_pen_combined, avg_pen_usd, avg_gold_spot_price');

      if (start != null) {
        query = query.gte('date_lima', start.toIso8601String().split('T').first);
      }

      final rows = await query.order('date_lima', ascending: true);
      final pts = <GoldTrendPoint>[];

      for (final r in rows) {
        final ts = DateTime.tryParse('${r['date_lima']}')?.toLocal();
        final usd = ((r['avg_gold_usd_combined'] as num?)?.toDouble()) ??
            ((r['avg_gold_spot_price'] as num?)?.toDouble());
        var pen = (r['avg_gold_pen_combined'] as num?)?.toDouble();
        final rate = (r['avg_pen_usd'] as num?)?.toDouble();
        if (pen == null && usd != null && rate != null) {
          pen = usd * rate;
        }

        if (ts == null) continue;
        final price = _currency == 'USD' ? usd : pen;
        if (price != null) pts.add(GoldTrendPoint(ts, price));
      }

      return pts;
    }

    late final List<GoldTrendPoint> pts;
    if (_range == TrendRange.diario) {
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      pts = _currency == 'USD'
          ? await loadCombinedTicks(start: start, end: end)
          : await loadLatestTicks(start: start, end: end);
    } else if (_range == TrendRange.semanal) {
      final start = now.subtract(const Duration(days: 7));
      pts = _currency == 'USD'
          ? await loadCombinedTicks(start: start)
          : await loadLatestTicks(start: start);
    } else if (_range == TrendRange.mensual) {
      final start = now.subtract(const Duration(days: 30));
      pts = await loadDailySummary(start: start);
    } else if (_range == TrendRange.anual) {
      final start = now.subtract(const Duration(days: 365));
      pts = await loadDailySummary(start: start);
    } else {
      pts = await loadDailySummary();
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

    final bidUsd = (spot?['bid'] as num?)?.toDouble();
    final askUsd = (spot?['ask'] as num?)?.toDouble();
    final changeAbs = (spot?['change_abs'] as num?)?.toDouble();
    final changePct = (spot?['change_pct'] as num?)?.toDouble();

    double? bid = bidUsd;
    double? ask = askUsd;
    if (_currency == 'PEN' && latestRate != null) {
      bid = bidUsd == null ? null : bidUsd * latestRate;
      ask = askUsd == null ? null : askUsd * latestRate;
    }

    final factor = _unitFactor(_unit);
    final convertedPts = pts
        .map((p) => GoldTrendPoint(p.time, p.price * factor))
        .toList(growable: false);
    bid = bid == null ? null : bid * factor;
    ask = ask == null ? null : ask * factor;
    final convertedChangeAbs =
        changeAbs == null ? null : changeAbs * factor;

    return GoldTrendState(
      range: _range,
      currency: _currency,
      unit: _unit,
      points: convertedPts,
      bid: bid,
      ask: ask,
      changeAbs: convertedChangeAbs,
      changePct: changePct,
    );
  }
}

final goldTrendViewModelProvider =
    AsyncNotifierProvider<GoldTrendViewModel, GoldTrendState>(
  () => GoldTrendViewModel(),
);
