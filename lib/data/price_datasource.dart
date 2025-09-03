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

  /// Returns the latest gold prices (gold spot and LBMA reference).
  Future<Map<String, double?>> fetchLatestGold() async {
    final row = await client
        .from('stg_latest_ticks')
        .select('gold_price, lbma_gold_am, lbma_gold_pm')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();

    Map<String, double?> toD(Map<String, dynamic>? m) =>
        (m ?? {}).map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : double.tryParse('$v')));
    return toD(row);
  }

  /// Returns the latest available spot price for gold in USD.
  ///
  /// The query filters by `metal_code` accepting common variants regardless of
  /// case, filters `currency` case-insensitively for USD, and picks the newest
  /// record by `captured_at`.
  Future<Map<String, double?>> fetchSpotGoldUsd() async {
    // Direct query; replace with `v_spot_latest` view when available.
    final q = client
        .from('stg_spot_ticks')
        .select('price, ask, bid, high, low, change_abs, change_pct')
        // Accept common variants of the metal code in a case-insensitive manner
        // `filter(..., 'in', ...)` used for compatibility with Postgrest 2.x
        // where `in_` was renamed. The filter is robust to case variations.
        .filter('metal_code', 'in',
            '("XAU","xau","GOLD","Gold","gold")')
        // Currency filter tolerant to case
        .ilike('currency', 'usd')
        .order('captured_at', ascending: false)
        .limit(1);

    final row = await q.maybeSingle();
    Map<String, double?> toD(Map<String, dynamic>? m) =>
        (m ?? {}).map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : double.tryParse('$v')));
    return toD(row);
  }
}

