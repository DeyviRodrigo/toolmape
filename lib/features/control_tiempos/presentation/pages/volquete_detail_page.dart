import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/operacion.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/widgets/toolmape_header.dart';

const _backgroundColor = Color(0xFF0B1220);
const _cardColor = Color(0xFF111827);
const _accentColor = Color(0xFFF59E0B);

class OperacionDetailResult {
  const OperacionDetailResult({this.operacionActualizada});

  final Operacion? operacionActualizada;
}

class OperacionDetailPage extends StatefulWidget {
  const OperacionDetailPage({
    super.key,
    required this.operacion,
  });

  final Operacion operacion;

  @override
  State<OperacionDetailPage> createState() => _OperacionDetailPageState();
}

class _OperacionDetailPageState extends State<OperacionDetailPage> {
  late Operacion _operacion;
  final DateFormat _dateFormat = DateFormat('d/M/yyyy HH:mm:ss');
  bool _hasReturned = false;

  @override
  void initState() {
    super.initState();
    _operacion = widget.operacion;
  }

  Future<void> _editar() async {
    final result = await Navigator.push<Operacion>(
      context,
      MaterialPageRoute(
        builder: (_) => OperacionFormPage(initial: _operacion),
      ),
    );

    if (result != null) {
      setState(() => _operacion = result);
    }
  }

  void _finalizar() {
    if (_operacion.estado.isCompleto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La operación ya está completa')),
      );
      return;
    }

    setState(() {
      _operacion = _operacion.copyWith(
        estado: EstadoOperacion.completo,
        fin: DateTime.now(),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operación finalizada')),
    );
    _closeWithResult();
  }

  void _closeWithResult() {
    if (_hasReturned) return;
    _hasReturned = true;
    Navigator.pop(
      context,
      OperacionDetailResult(operacionActualizada: _operacion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_hasReturned) {
          return true;
        }
        _closeWithResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: const ToolmapeHeader(),
        drawer: const Drawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Container(
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _operacion.actividad,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _DetailItem(
                      label: 'Maquinaria',
                      value: _operacion.maquinaria,
                    ),
                    _DetailItem(
                      label: 'Chutes',
                      value: _operacion.chute.toString(),
                    ),
                    _DetailItem(
                      label: 'Actividad',
                      value: _operacion.actividad,
                    ),
                    if (_operacion.volquete != null &&
                        _operacion.volquete!.isNotEmpty)
                      _DetailItem(
                        label: 'Volquete',
                        value: _operacion.volquete!,
                      ),
                    _DetailItem(
                      label: 'Inicio',
                      value: _dateFormat.format(_operacion.inicio),
                    ),
                    _DetailItem(
                      label: 'Final',
                      value: _operacion.fin != null
                          ? _dateFormat.format(_operacion.fin!)
                          : '—',
                    ),
                    _DetailItem(
                      label: 'Estado',
                      value: _operacion.estado.label,
                      valueColor: _operacion.estado.isCompleto
                          ? const Color(0xFF22C55E)
                          : _accentColor,
                    ),
                    if (_operacion.observaciones != null &&
                        _operacion.observaciones!.isNotEmpty)
                      _DetailItem(
                        label: 'Observaciones',
                        value: _operacion.observaciones!,
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FloatingEmojiButton(
                    emoji: '⏱️',
                    onPressed: _finalizar,
                  ),
                  const SizedBox(height: 12),
                  _FloatingEmojiButton(
                    emoji: '✏️',
                    onPressed: _editar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}


class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  letterSpacing: 0.2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _FloatingEmojiButton extends StatelessWidget {
  const _FloatingEmojiButton({
    required this.emoji,
    required this.onPressed,
  });

  final String emoji;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _accentColor,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
