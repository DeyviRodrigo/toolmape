import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../viewmodels/price_trends_view_model.dart';
import '../atoms/chart_legend_item.dart';

class WeeklyTrendsChart extends StatelessWidget {
  final List<WeeklyPoint> data;
  const WeeklyTrendsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    final goldSpots = data.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldUsd))
        .toList();
    final exSpots = data.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.exchangeRate))
        .toList();
    final penSpots = data.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldPen))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tendencia semanal'),
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
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final date = data[index].date;
                      return Text(dateFormat.format(date));
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
                LineChartBarData(spots: penSpots, color: Colors.blue),
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
            ChartLegendItem(color: Colors.blue, label: 'Oro (PEN)'),
          ],
        ),
      ],
    );
  }
}
