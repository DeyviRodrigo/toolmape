import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolmape/features/calculator/infrastructure/datasources/exchange_rate_datasource.dart';
import 'package:toolmape/features/calculator/infrastructure/datasources/price_datasource.dart';

typedef PrecioOroSelection = ({double? price, double? rate});

Future<PrecioOroSelection?> showPrecioOroAvanzadasDialog(
  BuildContext context, {
  PriceDatasource? datasource,
  ExchangeRateDatasource? exchangeDatasource,
}) async {
  return showDialog<PrecioOroSelection>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _PrecioOroAvanzadasDialog(
      datasource: datasource,
      exchangeDatasource: exchangeDatasource,
    ),
  );
}

class _PrecioOroAvanzadasDialog extends StatefulWidget {
  const _PrecioOroAvanzadasDialog({
    this.datasource,
    this.exchangeDatasource,
  });

  final PriceDatasource? datasource;
  final ExchangeRateDatasource? exchangeDatasource;

  @override
  State<_PrecioOroAvanzadasDialog> createState() =>
      _PrecioOroAvanzadasDialogState();
}

class _PrecioOroAvanzadasDialogState extends State<_PrecioOroAvanzadasDialog> {
  static const double _boxWidth = 80;
  static const double _spacing = 8;
  static const double _rowWidth = _boxWidth * 2 + _spacing;
  static const double _dialogWidth = _rowWidth + 32;
  Map<String, double?>? latest;
  Map<String, double?>? spot;
  DateTime? latestCapturedAt;
  DateTime? spotCapturedAt;
  DateTime? selectedDate;
  bool loading = true;
  bool spotError = false;
  double? rate;
  late final PriceDatasource _datasource;
  late final ExchangeRateDatasource _exchangeDatasource;

  @override
  void initState() {
    super.initState();
    _datasource =
        widget.datasource ?? PriceDatasource(Supabase.instance.client);
    _exchangeDatasource = widget.exchangeDatasource ??
        ExchangeRateDatasource(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    Map<String, double?>? latestRes;
    Map<String, double?>? spotRes;
    DateTime? latestTs;
    DateTime? spotTs;
    double? rateRes;
    var spotErr = false;
    try {
      final res = await _datasource.fetchLatestGold();
      latestRes = res.data;
      latestTs = res.capturedAt;
    } catch (_) {
      // ignore, latest will remain null
    }
    try {
      final res = await _datasource.fetchSpotGoldUsd();
      spotRes = res.data;
      spotTs = res.capturedAt;
    } catch (_) {
      spotErr = true;
    }
    try {
      final res = await _exchangeDatasource.fetchLatest();
      rateRes = res.value;
    } catch (_) {
      // ignore
    }

    if (spotErr) {
      // Show a discreet error but do not block UI
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo cargar Spot')));
    }

    setState(() {
      latest = latestRes;
      spot = spotRes;
      latestCapturedAt = latestTs;
      spotCapturedAt = spotTs;
      loading = false;
      spotError = spotErr;
      rate = rateRes;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2022, 1, 1),
      lastDate: now,
      initialDate: selectedDate ?? now,
    );
    if (picked != null) {
      final res = await _datasource.fetchDailySummary(picked);
      final rateRes = await _exchangeDatasource.fetchByDate(picked);
      setState(() {
        latest = res.latest;
        spot = res.spot;
        selectedDate = picked;
        latestCapturedAt = null;
        spotCapturedAt = null;
        rate = rateRes.value;
      });
    }
  }

  Widget _titleWithDate(String label, DateTime? ts) {
    final date = ts == null ? null : DateFormat('yyyy-MM-dd HH:mm').format(ts);
    return Text(
      date == null ? label : '$label ($date)',
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _selectableBox(String label, num? value) {
    final v = value?.toDouble();
    return SizedBox(
      width: _boxWidth,
      child: InkWell(
        onTap: v == null
            ? null
            : () => Navigator.pop(context, (price: v, rate: rate)),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(v?.toStringAsFixed(2) ?? '-', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String label, num? value) {
    final v = value?.toDouble();
    return SizedBox(
      width: _boxWidth,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              v == null
                  ? '-'
                  : label.contains('%')
                  ? '${v.toStringAsFixed(2)}%'
                  : v.toStringAsFixed(2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: _dialogWidth,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: loading
              ? const SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    _titleWithDate('Latest', latestCapturedAt),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectableBox('Gold', latest?['gold_price']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectableBox('LBMA AM', latest?['lbma_gold_am']),
                          const SizedBox(width: _spacing),
                          _selectableBox('LBMA PM', latest?['lbma_gold_pm']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _titleWithDate('Spot', spotCapturedAt),
                    if (spotError)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'No se pudo cargar Spot',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [_selectableBox('Precio', spot?['price'])],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectableBox('Ask', spot?['ask']),
                          const SizedBox(width: _spacing),
                          _selectableBox('Bid', spot?['bid']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectableBox('High', spot?['high']),
                          const SizedBox(width: _spacing),
                          _selectableBox('Low', spot?['low']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _infoBox('Cambio', spot?['change_abs']),
                          const SizedBox(width: _spacing),
                          _infoBox('Cambio %', spot?['change_pct']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _pickDate,
                      child: Text(
                        selectedDate == null
                            ? 'Elegir fecha'
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
