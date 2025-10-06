import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/theme/control_tiempos_palette.dart';

class VolqueteInfoPage extends StatelessWidget {
  VolqueteInfoPage({
    super.key,
    required this.volquete,
  }) : _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  final Volquete volquete;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ControlTiemposPalette.of(theme);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        foregroundColor: palette.primaryText,
        title: Text('Detalle de ${volquete.codigo}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.outline.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  volquete.maquinaria,
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: palette.primaryText,
                      ),
                ),
                const SizedBox(height: 8),
                _InfoRow(label: 'Procedencia', value: volquete.procedencias.join(' / ')),
                _InfoRow(label: 'Chute', value: 'Chute ${volquete.chute}'),
                _InfoRow(
                  label: 'Llegada a frente',
                  value: _dateFormat.format(volquete.llegadaFrente),
                ),
                _InfoRow(
                  label: 'Inicio de maniobra',
                  value: volquete.inicioManiobra == null
                      ? '—'
                      : _dateFormat.format(volquete.inicioManiobra!),
                ),
                _InfoRow(
                  label: 'Inicio de carga',
                  value: volquete.inicioCarga == null
                      ? '—'
                      : _dateFormat.format(volquete.inicioCarga!),
                ),
                _InfoRow(
                  label: 'Final de carga',
                  value: volquete.finCarga == null
                      ? '—'
                      : _dateFormat.format(volquete.finCarga!),
                ),
                const SizedBox(height: 12),
                _EstadoBadge(estado: volquete.estado),
                if (volquete.notas != null && volquete.notas!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Observaciones',
                    style: theme.textTheme.titleMedium?.copyWith(
                          color: palette.primaryText,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    volquete.notas!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.mutedText,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Registros vinculados',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: palette.primaryText,
                ),
          ),
          const SizedBox(height: 12),
          _DescargasDataTable(volquete: volquete, dateFormat: _dateFormat),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = ControlTiemposPalette.of(Theme.of(context));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: palette.subtleText,
                  letterSpacing: 0.4,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: palette.primaryText),
          ),
        ],
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final palette = ControlTiemposPalette.of(Theme.of(context));
    final bool completo = estado == VolqueteEstado.completo;
    final Color baseColor = completo ? palette.success : palette.accent;
    final Color background = baseColor.withOpacity(completo ? 0.18 : 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withOpacity(0.4)),
      ),
      child: Text(
        estado.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: baseColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _DescargasDataTable extends StatelessWidget {
  const _DescargasDataTable({required this.volquete, required this.dateFormat});

  final Volquete volquete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final palette = ControlTiemposPalette.of(Theme.of(context));
    if (volquete.descargas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Sin registros vinculados.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: palette.mutedText),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor:
            WidgetStatePropertyAll(palette.surface.withOpacity(0.4)),
        columns: [
          DataColumn(label: Text('Volquete', style: TextStyle(color: palette.mutedText))),
          DataColumn(label: Text('Procedencia', style: TextStyle(color: palette.mutedText))),
          DataColumn(label: Text('Chute', style: TextStyle(color: palette.mutedText))),
          DataColumn(label: Text('Fechas', style: TextStyle(color: palette.mutedText))),
        ],
        rows: volquete.descargas
            .map(
              (descarga) => DataRow(
                cells: [
                  DataCell(Text(descarga.volquete,
                      style: TextStyle(color: palette.primaryText))),
                  DataCell(Text(descarga.procedencia,
                      style: TextStyle(color: palette.primaryText))),
                  DataCell(Text(descarga.chute.toString(),
                      style: TextStyle(color: palette.primaryText))),
                  DataCell(
                    Text(
                      '${dateFormat.format(descarga.fechaInicio)}\n${dateFormat.format(descarga.fechaFin)}',
                      style: TextStyle(color: palette.subtleText),
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
