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
            : state.range == TrendRange.anual || state.range == TrendRange.general
                ? DateFormat('dd/MM/yyyy')
                : DateFormat('dd/MM');
        final tooltipFmt =
            state.range == TrendRange.diario || state.range == TrendRange.semanal
                ? DateFormat('dd/MM HH:mm')
                : DateFormat('dd/MM/yyyy');
        final rangeFmt = DateFormat('dd/MM/yyyy');
        final rangeText = state.from == null
            ? ''
            : '${rangeFmt.format(state.from!)} - ${rangeFmt.format(state.to!)}';
        final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
        final baseTextColor = isDarkTheme ? Colors.white : Colors.black;
        final currencySymbol = state.currency == 'PEN' ? 'S/' : r'$';
        final numberFormat = NumberFormat('#,##0.00', 'en_US');
        String formatCurrency(num? value, {bool signed = false}) {
          if (value == null) return '--';
          final magnitude = numberFormat.format(value.abs());
          final sign = value < 0
              ? '-'
              : signed && value > 0
                  ? '+'
                  : '';
          return '$sign$currencySymbol $magnitude';
        }
        Color chColor(double? v) => v == null
            ? Colors.black
            : (v >= 0 ? Colors.green : Colors.red);
        Widget metric(
          String label,
          double? value, {
          bool colored = false,
          Color? valueColor,
          bool asCurrency = false,
          bool signed = false,
          String? suffix,
        }) {
          final numberColor =
              colored ? chColor(value) : valueColor ?? baseTextColor;
          final txt = value == null
              ? '--'
              : asCurrency
                  ? formatCurrency(value, signed: signed)
                  : '${value.toStringAsFixed(2)}${suffix ?? ''}';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: baseTextColor),
              ),
              Text(txt, style: TextStyle(fontSize: 12, color: numberColor)),
            ],
          );
        }

        String unitLabel(GoldUnit unit) {
          switch (unit) {
            case GoldUnit.toz:
              return 'toz';
            case GoldUnit.gram:
              return 'g';
            case GoldUnit.kilogram:
              return 'kg';
          }
        }

        void showFiltersSheet() {
          showModalBottomSheet<void>(
            context: context,
            builder: (modalContext) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Filtros',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TrendRange>(
                        value: state.range,
                        onChanged: (value) {
                          if (value != null) {
                            vm.setRange(value);
                          }
                        },
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
                          DropdownMenuItem(
                            value: TrendRange.general,
                            child: Text('General'),
                          ),
                        ],
                        decoration: const InputDecoration(labelText: 'Tiempo'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: state.currency,
                        onChanged: (value) {
                          if (value != null) {
                            vm.setCurrency(value);
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'PEN', child: Text('PEN')),
                        ],
                        decoration: const InputDecoration(labelText: 'Moneda'),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<GoldUnit>(
                        value: state.unit,
                        onChanged: (value) {
                          if (value != null) {
                            vm.setUnit(value);
                          }
                        },
                        items: GoldUnit.values
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(unitLabel(u)),
                              ),
                            )
                            .toList(),
                        decoration: const InputDecoration(labelText: 'Unidad'),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(modalContext).pop(),
                          child: const Text('Cerrar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final compactFilters = constraints.maxWidth < 520;
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          metric(
                            'BID',
                            state.bid,
                            valueColor: baseTextColor,
                            asCurrency: true,
                          ),
                          metric(
                            'ASK',
                            state.ask,
                            valueColor: baseTextColor,
                            asCurrency: true,
                          ),
                          metric(
                            '+/-',
                            state.changeAbs,
                            colored: true,
                            asCurrency: true,
                            signed: true,
                          ),
                          metric(
                            '%',
                            state.changePct,
                            colored: true,
                            suffix: '%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (compactFilters)
                      ElevatedButton.icon(
                        onPressed: showFiltersSheet,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filtros'),
                      )
                    else
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
                              DropdownMenuItem(
                                value: TrendRange.general,
                                child: Text('General'),
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
                          const SizedBox(width: 8),
                          DropdownButton<GoldUnit>(
                            value: state.unit,
                            onChanged: (v) => v == null ? null : vm.setUnit(v),
                            items: GoldUnit.values
                                .map(
                                  (u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(unitLabel(u)),
                                  ),
                                )
                                .toList(),
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
                            final price =
                                '${formatCurrency(e.y)} ${unitLabel(state.unit)}';
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
                            interval: (pts.length / 5)
                                .ceilToDouble()
                                .clamp(1, double.infinity),
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= pts.length) {
                                return const SizedBox.shrink();
                              }
                              final d = pts[idx].time;
                              return Text(
                                dateFmt.format(d),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Precio (${state.currency}/${unitLabel(state.unit)})',
                              style: TextStyle(fontSize: 12, color: baseTextColor),
                            ),
                          ),
                          axisNameSize: 36,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80,
                            getTitlesWidget: (value, meta) => Text(
                              formatCurrency(value),
                              style: TextStyle(
                                fontSize: 10,
                                color: baseTextColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                        topTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
