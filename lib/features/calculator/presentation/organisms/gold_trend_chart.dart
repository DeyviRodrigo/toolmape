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
        final tooltipFmt =
            state.range == TrendRange.diario || state.range == TrendRange.semanal
                ? DateFormat('dd/MM HH:mm')
                : DateFormat('dd/MM/yyyy');
        final rangeFmt = DateFormat('dd/MM/yyyy');
        final rangeText = state.from == null
            ? ''
            : '${rangeFmt.format(state.from!)} - ${rangeFmt.format(state.to!)}';
        Color chColor(double? v) => v == null
            ? Colors.black
            : (v >= 0 ? Colors.green : Colors.red);
        Widget metric(
          String label,
          double? value, {
          bool colored = false,
          Color? valueColor,
        }) {
          final numberColor = colored ? chColor(value) : valueColor ?? Colors.white;
          final txt = value == null ? '--' : value.toStringAsFixed(2);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
              Text(txt, style: TextStyle(fontSize: 12, color: numberColor)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gráfico de tendencias del precio del oro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      metric('BID', state.bid, valueColor: Colors.white),
                      const SizedBox(width: 8),
                      metric('ASK', state.ask, valueColor: Colors.white),
                      const SizedBox(width: 8),
                      metric('+/-', state.changeAbs, colored: true),
                      const SizedBox(width: 8),
                      metric('%', state.changePct, colored: true),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: state.currency,
                      onChanged: (v) => v == null ? null : vm.setCurrency(v),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'PEN', child: Text('PEN')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) => touchedSpots.map((e) {
                        final idx = e.x.toInt();
                        final date =
                            idx >= 0 && idx < pts.length ? pts[idx].time : null;
                        final dateStr =
                            date == null ? '' : tooltipFmt.format(date);
                        final price = e.y.toStringAsFixed(2);
                        final text = dateStr.isEmpty ? price : '$price\n$dateStr';
                        return LineTooltipItem(
                          text,
                          const TextStyle(color: Colors.white),
                        );
                      }).toList(),
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
                        reservedSize: 56,
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
                    LineChartBarData(
                      spots: spots,
                      color: Colors.red,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 2,
                          color: Colors.red,
                          strokeWidth: 0,
                        ),
                      ),
                    ),
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
