import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ForecastChart extends StatelessWidget {
  final List<double> goldForecast;
  final List<double> exchangeForecast;
  const ForecastChart({super.key, required this.goldForecast, required this.exchangeForecast});

  @override
  Widget build(BuildContext context) {
    final goldSpots = goldForecast.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final exSpots = exchangeForecast.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(spots: goldSpots, color: Colors.amber),
            LineChartBarData(spots: exSpots, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
