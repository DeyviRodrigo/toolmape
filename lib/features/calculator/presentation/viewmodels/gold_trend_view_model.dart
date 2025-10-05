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
    final rateRow = await client
        .from('stg_latest_ticks')
        .select('pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final latestRate = (rateRow?['pen_usd'] as num?)?.toDouble();

    Future<List<GoldTrendPoint>> loadPoints({
      required DateTime start,
      DateTime? end,
      required bool bucketByDay,
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
        final converted = _currency == 'USD'
            ? gold
            : (latestRate == null ? null : gold * latestRate);
        if (converted == null) continue;

        if (bucketByDay) {
          final key =
              '${ts.year.toString().padLeft(4, '0')}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
          final existing = dedup[key];
          if (existing == null || ts.isAfter(existing.time)) {
            dedup[key] = GoldTrendPoint(ts, converted);
          }
        } else {
          dedup[ts.toIso8601String()] = GoldTrendPoint(ts, converted);
        }
      }

      final pts = dedup.values.toList()
        ..sort((a, b) => a.time.compareTo(b.time));
      return pts;
    }

    late final List<GoldTrendPoint> pts;
    if (_range == TrendRange.diario) {
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      pts = await loadPoints(start: start, end: end, bucketByDay: false);
    } else if (_range == TrendRange.semanal) {
      final start = now.subtract(const Duration(days: 7));
      pts = await loadPoints(start: start, bucketByDay: false);
    } else {
      final days = _range == TrendRange.mensual ? 30 : 365;
      final start = now.subtract(Duration(days: days));
      pts = await loadPoints(start: start, bucketByDay: true);
    }

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
