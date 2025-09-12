import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/exchange_rate_datasource.dart';

Future<double?> showTipoCambioAvanzadasDialog(
  BuildContext context, {
  ExchangeRateDatasource? datasource,
}) async {
  return showDialog<double>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _TipoCambioAvanzadasDialog(datasource: datasource),
  );
}

class _TipoCambioAvanzadasDialog extends StatefulWidget {
  const _TipoCambioAvanzadasDialog({this.datasource});

  final ExchangeRateDatasource? datasource;

  @override
  State<_TipoCambioAvanzadasDialog> createState() =>
      _TipoCambioAvanzadasDialogState();
}

class _TipoCambioAvanzadasDialogState
    extends State<_TipoCambioAvanzadasDialog> {
  double? rate;
  DateTime? capturedAt;
  DateTime? selectedDate;
  bool loading = true;
  late final ExchangeRateDatasource _datasource;

  @override
  void initState() {
    super.initState();
    _datasource =
        widget.datasource ?? ExchangeRateDatasource(Supabase.instance.client);
    _load();
  }

  Future<void> _load() async {
    final res = await _datasource.fetchLatest();
    setState(() {
      rate = res.value;
      capturedAt = res.capturedAt;
      loading = false;
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
      setState(() => loading = true);
      final res = await _datasource.fetchByDate(picked);
      setState(() {
        selectedDate = picked;
        rate = res.value;
        capturedAt = res.capturedAt;
        loading = false;
      });
    }
  }

  String _title() {
    if (capturedAt == null) return 'PEN/USD';
    final date = DateFormat('yyyy-MM-dd HH:mm').format(capturedAt!);
    return 'PEN/USD ($date)';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 160,
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
                    Text(
                      _title(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: rate == null
                          ? null
                          : () => Navigator.pop(context, rate),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rate?.toStringAsFixed(2) ?? '-',
                          textAlign: TextAlign.center,
                        ),
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
