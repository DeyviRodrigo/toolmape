import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../viewmodels/price_trends_view_model.dart';

class AnnualGoldChart extends StatelessWidget {
  final List<({DateTime date, double goldUsd})> data;
  const AnnualGoldChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = data.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.goldUsd))
        .toList();
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(spots: spots, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
