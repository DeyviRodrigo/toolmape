import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/excavadora_operacion.dart';

class ExcavadoraOperacionDetailPage extends StatelessWidget {
  ExcavadoraOperacionDetailPage({super.key, required this.operacion})
      : _dateFormat = DateFormat('d/M/yyyy HH:mm');

  final ExcavadoraOperacion operacion;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    final bool estaCompleta = operacion.estaCompleta;
    final Color statusColor = estaCompleta
        ? const Color(0xFF34D399)
        : const Color(0xFFFBBF24);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(operacion.actividad),
        actions: [
          IconButton(
            tooltip: 'Finalizar operación',
            icon: Icon(
              Icons.timer_outlined,
              color: estaCompleta ? Colors.grey.shade600 : Colors.grey.shade200,
            ),
            onPressed: estaCompleta
                ? null
                : () => Navigator.pop(
                      context,
                      const ExcavadoraOperacionDetailResult(finalizar: true),
                    ),
          ),
          IconButton(
            tooltip: 'Editar',
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade200),
            onPressed: () => Navigator.pop(
              context,
              const ExcavadoraOperacionDetailResult(editar: true),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailHeader(
                maquinaria: operacion.maquinaria,
                estado: estaCompleta ? 'Completo' : 'Incompleto',
                estadoColor: statusColor,
              ),
              const SizedBox(height: 24),
              _DetailItem(
                title: 'Chute',
                value: operacion.chute.toString(),
              ),
              _DetailItem(
                title: 'Actividad',
                value: operacion.actividad,
              ),
              if (operacion.volquete != null)
                _DetailItem(
                  title: 'Volquete asociado',
                  value: operacion.volquete!,
                ),
              _DetailItem(
                title: 'Inicio',
                value: _dateFormat.format(operacion.inicio),
              ),
              _DetailItem(
                title: 'Final',
                value: operacion.fin != null
                    ? _dateFormat.format(operacion.fin!)
                    : 'Pendiente',
              ),
              _DetailItem(
                title: 'Estado',
                value: estaCompleta ? 'Completo' : 'Incompleto',
                valueColor: statusColor,
              ),
              if ((operacion.observaciones ?? '').isNotEmpty)
                _DetailItem(
                  title: 'Observaciones',
                  value: operacion.observaciones!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.maquinaria,
    required this.estado,
    required this.estadoColor,
  });

  final String maquinaria;
  final String estado;
  final Color estadoColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            maquinaria,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ) ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            estado,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: estadoColor,
                  fontWeight: FontWeight.w600,
                ) ??
                TextStyle(
                  color: estadoColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = Colors.white.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: labelColor,
                  letterSpacing: 0.5,
                ) ??
                TextStyle(
                  color: labelColor,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ) ??
                TextStyle(
                  color: valueColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class ExcavadoraOperacionDetailResult {
  const ExcavadoraOperacionDetailResult({
    this.editar = false,
    this.finalizar = false,
  });

  final bool editar;
  final bool finalizar;
}
