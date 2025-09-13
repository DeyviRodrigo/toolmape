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
        .from('latest')
        .select('captured_at, pen_usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return (
      value: _toD(row?['pen_usd']),
      capturedAt: _toTs(row?['captured_at']),
    );
  }

  /// Returns the exchange rate and gold spot price for [date]. If no record
  /// exists for that date, it looks up to two days earlier and returns the first
  /// values found.
  Future<({double? value, double? goldPrice, DateTime? capturedAt})>
      fetchByDate(DateTime date) async {
    for (var i = 0; i < 3; i++) {
      final d =
          DateTime(date.year, date.month, date.day).subtract(Duration(days: i));
      final row = await client
          .from('fact_daily_summary')
          .select('date_lima, avg_pen_usd, avg_gold_spot_price')
          .eq('date_lima', d.toIso8601String().split('T').first)
          .maybeSingle();
      final value = _toD(row?['avg_pen_usd']);
      final gold = _toD(row?['avg_gold_spot_price']);
      if (value != null) {
        return (
          value: value,
          goldPrice: gold,
          capturedAt: _toTs(row?['date_lima']),
        );
      }
    }
    return (value: null, goldPrice: null, capturedAt: null);
  }
}
