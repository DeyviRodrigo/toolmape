import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<double?> showPrecioOroAvanzadasDialog(BuildContext context) async {
  return showDialog<double>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _PrecioOroAvanzadasDialog(),
  );
}

class _PrecioOroAvanzadasDialog extends StatefulWidget {
  const _PrecioOroAvanzadasDialog();

  @override
  State<_PrecioOroAvanzadasDialog> createState() => _PrecioOroAvanzadasDialogState();
}

class _PrecioOroAvanzadasDialogState extends State<_PrecioOroAvanzadasDialog> {
  static const double _boxWidth = 80;
  static const double _spacing = 8;
  static const double _rowWidth = _boxWidth * 2 + _spacing;
  static const double _dialogWidth = _rowWidth + 32;

  Map<String, dynamic>? latest;
  Map<String, dynamic>? spot;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final client = Supabase.instance.client;
      final latestRes = await client
          .from('stg_latest_ticks')
          .select('gold_price, lbma_gold_am, lbma_gold_pm')
          .order('captured_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final spotRes = await client
          .from('stg_spot_ticks')
          .select('price, ask, bid, high, low, change_abs, change_pct')
          .eq('metal_code', 'XAU')
          .order('captured_at', ascending: false)
          .limit(1)
          .maybeSingle();
      setState(() {
        latest = latestRes;
        spot = spotRes;
        loading = false;
      });
    } catch (_) {
      setState(() {
        loading = false;
      });
    }
  }

  Widget _selectableBox(String label, num? value) {
    final v = value?.toDouble();
    return SizedBox(
      width: _boxWidth,
      child: InkWell(
        onTap: v == null ? null : () => Navigator.pop(context, v),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
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
          border: Border.all(color: Colors.grey.shade400),
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
                    Text('Latest',
                        style: Theme.of(context).textTheme.titleMedium),
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
                    Text('Spot',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: _rowWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectableBox('Precio', spot?['price']),
                        ],
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
                  ],
                ),
        ),
      ),
    );
  }
}


