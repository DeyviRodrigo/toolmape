import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ml_arima/ml_sarima.dart';

class WeeklyPoint {
  final DateTime date;
  final double goldUsd;
  final double exchangeRate;
  const WeeklyPoint({required this.date, required this.goldUsd, required this.exchangeRate});
  double get goldPen => goldUsd * exchangeRate;
}

class PriceTrendsState {
  final List<WeeklyPoint> weekly;
  final List<({DateTime date, double goldUsd})> annual;
  final List<double> forecastGold;
  final List<double> forecastExchange;
  const PriceTrendsState({
    required this.weekly,
    required this.annual,
    required this.forecastGold,
    required this.forecastExchange,
  });
}

class PriceTrendsViewModel extends AsyncNotifier<PriceTrendsState> {
  @override
  Future<PriceTrendsState> build() async {
    final client = Supabase.instance.client;
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekRows = await client
        .from('fact_daily_summary')
        .select('date_lima, avg_gold_spot_price, avg_pen_usd')
        .gte('date_lima', weekStart.toIso8601String().split('T').first)
        .order('date_lima')
        .limit(7);
    final weekly = <WeeklyPoint>[];
    for (final r in weekRows) {
      final date = DateTime.tryParse('${r['date_lima']}')?.toLocal() ?? now;
      final gold = (r['avg_gold_spot_price'] as num?)?.toDouble() ?? 0.0;
      final ex = (r['avg_pen_usd'] as num?)?.toDouble() ?? 0.0;
      weekly.add(WeeklyPoint(date: date, goldUsd: gold, exchangeRate: ex));
    }

    final yearStart = now.subtract(const Duration(days: 365));
    final yearRows = await client
        .from('fact_daily_summary')
        .select('date_lima, avg_gold_spot_price')
        .gte('date_lima', yearStart.toIso8601String().split('T').first)
        .order('date_lima');
    final annual = <({DateTime date, double goldUsd})>[];
    for (final r in yearRows) {
      final date = DateTime.tryParse('${r['date_lima']}')?.toLocal() ?? now;
      final gold = (r['avg_gold_spot_price'] as num?)?.toDouble() ?? 0.0;
      annual.add((date: date, goldUsd: gold));
    }

    final goldSeries = weekly.map((e) => e.goldUsd).toList();
    final exSeries = weekly.map((e) => e.exchangeRate).toList();
    final goldFit = Sarima.autoSarima(goldSeries, s: 7);
    final exFit = Sarima.autoSarima(exSeries, s: 7);
    final goldForecast = Sarima.forecast(goldSeries, goldFit, 3).point;
    final exForecast = Sarima.forecast(exSeries, exFit, 3).point;

    return PriceTrendsState(
      weekly: weekly,
      annual: annual,
      forecastGold: goldForecast,
      forecastExchange: exForecast,
    );
  }
}

final priceTrendsViewModelProvider =
    AsyncNotifierProvider<PriceTrendsViewModel, PriceTrendsState>(
  () => PriceTrendsViewModel(),
);
