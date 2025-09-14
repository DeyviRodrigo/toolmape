import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../viewmodels/price_trends_view_model.dart';
import '../atoms/chart_legend_item.dart';

class AnnualGoldChart extends StatelessWidget {
  final List<({DateTime date, double goldUsd})> data;
  const AnnualGoldChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMM');
    final spots = data.asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldUsd))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Precio anual del oro'),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Mes'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final date = data[index].date;
                      return Text(monthFormat.format(date));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('USD'),
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
                LineChartBarData(spots: spots, color: Colors.amber),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const ChartLegendItem(color: Colors.amber, label: 'Oro (USD)'),
      ],
    );
  }
}
