import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../viewmodels/price_trends_view_model.dart';

class WeeklyTrendsChart extends StatelessWidget {
  final List<WeeklyPoint> data;
  const WeeklyTrendsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final goldSpots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldUsd))
        .toList();
    final exSpots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.exchangeRate))
        .toList();
    final penSpots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldPen))
        .toList();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(spots: goldSpots, color: Colors.amber),
            LineChartBarData(spots: exSpots, color: Colors.green),
            LineChartBarData(spots: penSpots, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
