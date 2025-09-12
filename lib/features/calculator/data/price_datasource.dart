import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for gold prices fetched from Supabase.
///
/// Queries always sort by `captured_at` in descending order and limit to a
/// single row to guarantee the latest available record.
///
/// Optional database view and index that can replace the direct query used in
/// [fetchSpotGoldUsd]:
/// ```sql
/// create or replace view public.v_spot_latest as
/// select distinct on (metal_code, currency)
///   captured_at, currency, unit, metal_code,
///   price, ask, bid, high, low, change_abs, change_pct
/// from public.stg_spot_ticks
/// order by metal_code, currency, captured_at desc;
///
/// create index if not exists idx_spot_metal_curr_ts
///   on public.stg_spot_ticks (metal_code, currency, captured_at desc);
/// ```
class PriceDatasource {
  final SupabaseClient client;
  PriceDatasource(this.client);

  /// Parses a dynamic value to double.
  double? _toD(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v');

  /// Returns the latest gold prices (gold spot and LBMA reference) and the time
  /// when they were captured.
  Future<({Map<String, double?> data, DateTime? capturedAt})>
  fetchLatestGold() async {
    final row = await client
        .from('stg_latest_ticks')
        .select('captured_at, gold_price, lbma_gold_am, lbma_gold_pm')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();

    final capturedAt = row == null
        ? null
        : DateTime.tryParse('${row['captured_at']}')?.toLocal();

    final data = <String, double?>{
      'gold_price': _toD(row?['gold_price']),
      'lbma_gold_am': _toD(row?['lbma_gold_am']),
      'lbma_gold_pm': _toD(row?['lbma_gold_pm']),
    };

    return (data: data, capturedAt: capturedAt);
  }

  /// Returns the latest available spot price for gold in USD and the time when
  /// it was captured.
  ///
  /// The query filters by `metal_code` accepting common variants regardless of
  /// case, filters `currency` case-insensitively for USD, and picks the newest
  /// record by `captured_at`.
  Future<({Map<String, double?> data, DateTime? capturedAt})>
  fetchSpotGoldUsd() async {
    // Direct query; replace with `v_spot_latest` view when available.
    final q = client
        .from('stg_spot_ticks')
        .select(
          'captured_at, price, ask, bid, high, low, change_abs, change_pct',
        )
        // Accept common variants of the metal code in a case-insensitive manner
        // `filter(..., 'in', ...)` used for compatibility with Postgrest 2.x
        // where `in_` was renamed. The filter is robust to case variations.
        .filter('metal_code', 'in', '("XAU","xau","GOLD","Gold","gold")')
        // Currency filter tolerant to case
        .ilike('currency', 'usd')
        .order('captured_at', ascending: false)
        .limit(1);

    final row = await q.maybeSingle();
    final capturedAt = row == null
        ? null
        : DateTime.tryParse('${row['captured_at']}')?.toLocal();

    final data = <String, double?>{
      'price': _toD(row?['price']),
      'ask': _toD(row?['ask']),
      'bid': _toD(row?['bid']),
      'high': _toD(row?['high']),
      'low': _toD(row?['low']),
      'change_abs': _toD(row?['change_abs']),
      'change_pct': _toD(row?['change_pct']),
    };

    return (data: data, capturedAt: capturedAt);
  }

  /// Returns the daily summary for a given date (`date_lima`).
  Future<({Map<String, double?> latest, Map<String, double?> spot})>
  fetchDailySummary(DateTime date) async {
    final row = await client
        .from('fact_daily_summary')
        .select(
          'avg_gold_latest_price, lbma_gold_am, lbma_gold_pm, avg_gold_spot_price, avg_gold_spot_ask, avg_gold_spot_bid, avg_gold_spot_high, avg_gold_spot_low',
        )
        .eq('date_lima', date.toIso8601String().split('T').first)
        .maybeSingle();

    final latest = <String, double?>{
      'gold_price': _toD(row?['avg_gold_latest_price']),
      'lbma_gold_am': _toD(row?['lbma_gold_am']),
      'lbma_gold_pm': _toD(row?['lbma_gold_pm']),
    };

    final spot = <String, double?>{
      'price': _toD(row?['avg_gold_spot_price']),
      'ask': _toD(row?['avg_gold_spot_ask']),
      'bid': _toD(row?['avg_gold_spot_bid']),
      'high': _toD(row?['avg_gold_spot_high']),
      'low': _toD(row?['avg_gold_spot_low']),
    };

    return (latest: latest, spot: spot);
  }
}
