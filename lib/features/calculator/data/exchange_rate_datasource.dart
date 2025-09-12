import 'package:supabase_flutter/supabase_flutter.dart';

/// Data source for PEN/USD exchange rates fetched from Supabase.
class ExchangeRateDatasource {
  final SupabaseClient client;
  ExchangeRateDatasource(this.client);

  double? _toD(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v');
  DateTime? _toTs(dynamic v) => DateTime.tryParse('$v')?.toLocal();

  /// Returns the latest available PEN/USD exchange rate and when it was captured.
  Future<({double? value, DateTime? capturedAt})> fetchLatest() async {
    final row = await client
        .from('stg_latest_ticks')
        .select('captured_at, pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return (
      value: _toD(row?['pen_usd']),
      capturedAt: _toTs(row?['captured_at']),
    );
  }

  /// Returns the exchange rate for [date]. If no record exists for that date,
  /// it looks up to two days earlier and returns the first value found.
  Future<({double? value, DateTime? capturedAt})> fetchByDate(DateTime date) async {
    for (var i = 0; i < 3; i++) {
      final d = DateTime(date.year, date.month, date.day).subtract(Duration(days: i));
      final start = d.toUtc().toIso8601String();
      final end = d.add(const Duration(days: 1)).toUtc().toIso8601String();
      final row = await client
          .from('stg_latest_ticks')
          .select('captured_at, pen_usd')
          .gte('captured_at', start)
          .lt('captured_at', end)
          .order('captured_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final value = _toD(row?['pen_usd']);
      if (value != null) {
        return (value: value, capturedAt: _toTs(row?['captured_at']));
      }
    }
    return (value: null, capturedAt: null);
  }
}
