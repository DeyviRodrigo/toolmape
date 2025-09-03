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
  Map<String, dynamic>? data;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await Supabase.instance.client
          .from('stg_spot_ticks')
          .select('price, ask, bid, high, low, change_abs, change_pct')
          .eq('metal_code', 'XAU')
          .order('captured_at', ascending: false)
          .limit(1)
          .single();
      setState(() {
        data = res;
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
    return Expanded(
      child: InkWell(
        onTap: v == null ? null : () => Navigator.pop(context, v),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(v?.toStringAsFixed(2) ?? '-'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String label, num? value) {
    final v = value?.toDouble();
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(v == null
                ? '-'
                : label.contains('%')
                    ? '${v.toStringAsFixed(2)}%'
                    : v.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  _selectableBox('Precio', data?['price']),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _selectableBox('Ask', data?['ask']),
                      const SizedBox(width: 8),
                      _selectableBox('Bid', data?['bid']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _selectableBox('High', data?['high']),
                      const SizedBox(width: 8),
                      _selectableBox('Low', data?['low']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoBox('Cambio', data?['change_abs']),
                      const SizedBox(width: 8),
                      _infoBox('Cambio %', data?['change_pct']),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

