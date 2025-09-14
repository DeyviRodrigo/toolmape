import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../viewmodels/gold_trend_view_model.dart';

class GoldTrendChart extends ConsumerWidget {
  const GoldTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(goldTrendViewModelProvider);
    final vm = ref.read(goldTrendViewModelProvider.notifier);
    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
      data: (state) {
        final pts = state.points;
        final spots = pts
            .asMap()
            .entries
            .map((e) => FlSpot(e.key.toDouble(), e.value.price))
            .toList();
        final dateFmt = state.range == TrendRange.diario
            ? DateFormat.Hm()
            : DateFormat('dd/MM');
        final rangeFmt = DateFormat('dd/MM/yyyy');
        final rangeText = state.from == null
            ? ''
            : '${rangeFmt.format(state.from!)} - ${rangeFmt.format(state.to!)}';
        Color chColor(double? v) => v == null
            ? Colors.black
            : (v >= 0 ? Colors.green : Colors.red);
        Widget metric(String label, double? value, {bool colored = false}) {
          final style = TextStyle(
            fontSize: 12,
            color: colored ? chColor(value) : Colors.black,
          );
          final txt = value == null ? '--' : value.toStringAsFixed(2);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(txt, style: style),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gráfico de tendencias del precio del oro',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<TrendRange>(
                  value: state.range,
                  onChanged: (v) => v == null ? null : vm.setRange(v),
                  items: const [
                    DropdownMenuItem(
                      value: TrendRange.diario,
                      child: Text('Diario'),
                    ),
                    DropdownMenuItem(
                      value: TrendRange.semanal,
                      child: Text('Semanal'),
                    ),
                    DropdownMenuItem(
                      value: TrendRange.mensual,
                      child: Text('Mensual'),
                    ),
                    DropdownMenuItem(
                      value: TrendRange.anual,
                      child: Text('Anual'),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: state.currency,
                  onChanged: (v) => v == null ? null : vm.setCurrency(v),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'PEN', child: Text('PEN')),
                  ],
                ),
                metric('BID', state.bid),
                metric('ASK', state.ask),
                metric('+/-', state.changeAbs, colored: true),
                metric('%', state.changePct, colored: true),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: false,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots
                          .map(
                            (e) => LineTooltipItem(
                              e.y.toStringAsFixed(2),
                              const TextStyle(color: Colors.white),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (pts.length / 5).ceilToDouble().clamp(1, double.infinity),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= pts.length) {
                            return const SizedBox.shrink();
                          }
                          final d = pts[idx].time;
                          return Text(dateFmt.format(d), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(spots: spots, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (rangeText.isNotEmpty)
              Text(
                rangeText,
                textAlign: TextAlign.center,
              ),
          ],
        );
      },
    );
  }
}
