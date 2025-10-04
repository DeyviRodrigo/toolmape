import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/operacion.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/widgets/toolmape_header.dart';

const _cardBackground = Color(0xFF111827);
const _pageBackground = Color(0xFF0B1220);
const _accentColor = Color(0xFFF59E0B);

/// Página principal que muestra el listado de operaciones de excavadora.
class ControlTiemposPage extends StatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  State<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

class _ControlTiemposPageState extends State<ControlTiemposPage> {
  final DateFormat _dateFormat = DateFormat('d/M/yyyy HH:mm:ss');
  late List<Operacion> _operaciones;

  @override
  void initState() {
    super.initState();
    _operaciones = List<Operacion>.from(_operacionesSemilla);
  }

  void _insertOrUpdate(Operacion operacion) {
    setState(() {
      final index = _operaciones.indexWhere((item) => item.id == operacion.id);
      if (index >= 0) {
        _operaciones[index] = operacion;
      } else {
        _operaciones = [operacion, ..._operaciones];
      }
    });
  }

  Future<void> _openForm({Operacion? initial}) async {
    final result = await Navigator.push<Operacion>(
      context,
      MaterialPageRoute(
        builder: (_) => OperacionFormPage(initial: initial),
      ),
    );

    if (result != null) {
      _insertOrUpdate(result);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(initial == null
              ? 'Operación registrada correctamente'
              : 'Operación actualizada'),
        ),
      );
    }
  }

  Future<void> _openDetail(Operacion operacion) async {
    final result = await Navigator.push<OperacionDetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => OperacionDetailPage(operacion: operacion),
      ),
    );

    if (result?.operacionActualizada != null) {
      _insertOrUpdate(result!.operacionActualizada!);
    }
  }

  void _finalizarDesdeLista(Operacion operacion) {
    if (operacion.estado.isCompleto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La operación ya está completa')),
      );
      return;
    }

    final actualizado = operacion.copyWith(
      estado: EstadoOperacion.completo,
      fin: DateTime.now(),
    );

    _insertOrUpdate(actualizado);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Operación marcada como completa')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: const ToolmapeHeader(),
      drawer: const Drawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
        itemCount: _operaciones.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final operacion = _operaciones[index];
          return _OperacionCard(
            operacion: operacion,
            dateFormat: _dateFormat,
            onOpenDetail: () => _openDetail(operacion),
            onEdit: () => _openForm(initial: operacion),
            onFinalize: () => _finalizarDesdeLista(operacion),
          );
        },
      ),
    );
  }
}

class _OperacionCard extends StatelessWidget {
  const _OperacionCard({
    required this.operacion,
    required this.dateFormat,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onFinalize,
  });

  final Operacion operacion;
  final DateFormat dateFormat;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onFinalize;

  Color get _estadoColor => operacion.estado.isCompleto
      ? const Color(0xFF22C55E)
      : const Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operacion.actividad,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      operacion.maquinaria,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      dateFormat.format(operacion.inicio),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    operacion.estado.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _estadoColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EmojiAction(
                        emoji: '⏱️',
                        onTap: onFinalize,
                      ),
                      const SizedBox(width: 12),
                      _EmojiAction(
                        emoji: '✏️',
                        onTap: onEdit,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiAction extends StatelessWidget {
  const _EmojiAction({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

final List<Operacion> _operacionesSemilla = [
  Operacion(
    id: 'op-01',
    actividad: 'Carguío de Gravas',
    maquinaria: '(E02) Excav. C 340-02',
    chute: 4,
    inicio: DateTime(2025, 5, 17, 14, 52, 37),
    fin: DateTime(2025, 10, 4, 8, 26, 5),
    volquete: '(V07) Volqu. SR V2Q-718',
    estado: EstadoOperacion.completo,
  ),
  Operacion(
    id: 'op-02',
    actividad: 'Arranque y Preparación',
    maquinaria: '(E02) Excav. C 340-02',
    chute: 2,
    inicio: DateTime(2025, 5, 17, 11, 20, 15),
    estado: EstadoOperacion.incompleto,
  ),
  Operacion(
    id: 'op-03',
    actividad: 'Carguío de Gravas',
    maquinaria: '(E01) Excav. C 340-01',
    chute: 1,
    inicio: DateTime(2025, 5, 16, 9, 15, 0),
    estado: EstadoOperacion.completo,
  ),
  Operacion(
    id: 'op-04',
    actividad: 'Arranque y Preparación',
    maquinaria: '(E03) Excav. C 340-03',
    chute: 5,
    inicio: DateTime(2025, 5, 14, 16, 45, 30),
    estado: EstadoOperacion.incompleto,
  ),
];
