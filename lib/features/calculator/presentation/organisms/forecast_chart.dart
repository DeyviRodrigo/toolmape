import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../atoms/chart_legend_item.dart';

class ForecastChart extends StatelessWidget {
  final List<double> goldForecast;
  final List<double> exchangeForecast;
  const ForecastChart({
    super.key,
    required this.goldForecast,
    required this.exchangeForecast,
  });

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
        goldForecast.length, (i) => DateTime.now().add(Duration(days: i + 1)));
    final dateFormat = DateFormat('dd/MM');
    final goldSpots = goldForecast.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final exSpots = exchangeForecast.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pronóstico (3 días)'),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Día'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= dates.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(dateFormat.format(dates[index]));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('Valor'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) =>
                        Text(value.toStringAsFixed(0)),
                  ),
                ),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(spots: goldSpots, color: Colors.amber),
                LineChartBarData(spots: exSpots, color: Colors.green),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          children: const [
            ChartLegendItem(color: Colors.amber, label: 'Oro (USD)'),
            ChartLegendItem(color: Colors.green, label: 'Tipo de cambio'),
          ],
        ),
      ],
    );
  }
}
