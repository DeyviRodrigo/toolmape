import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

const Color _accentColor = Color(0xFFFF9F1C);
const Color _backgroundColor = Color(0xFF121212);
const Color _surfaceColor = Color(0xFF1E1E1E);

class VolqueteInfoPage extends StatelessWidget {
  VolqueteInfoPage({
    super.key,
    required this.volquete,
  }) : _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  final Volquete volquete;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = Theme.of(context);
    final ThemeData themed = baseTheme.copyWith(
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _accentColor,
        secondary: _accentColor,
        surface: _backgroundColor,
        background: _backgroundColor,
        onSurface: Colors.white,
        onPrimary: Colors.black,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
      ),
    );

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text('Detalle de ${volquete.codigo}'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    volquete.maquinaria,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(volquete.notas!, style: const TextStyle(color: Colors.white70)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registros vinculados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _DescargasDataTable(volquete: volquete, dateFormat: _dateFormat),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.4),
          ),
          const SizedBox(height: 2),
          Text(value),
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
    final bool completo = estado == VolqueteEstado.completo;
    final Color background = completo
        ? const Color(0xFF1B5E20)
        : _accentColor.withOpacity(0.25);
    final Color textColor = completo ? const Color(0xFFBBF7D0) : _accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withOpacity(0.4)),
      ),
      child: Text(
        estado.label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
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
    if (volquete.descargas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Sin registros vinculados.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(Colors.white10),
        columns: const [
          DataColumn(label: Text('Volquete')),
          DataColumn(label: Text('Procedencia')),
          DataColumn(label: Text('Chute')),
          DataColumn(label: Text('Fechas')),
        ],
        rows: volquete.descargas
            .map(
              (descarga) => DataRow(
                cells: [
                  DataCell(Text(descarga.volquete)),
                  DataCell(Text(descarga.procedencia)),
                  DataCell(Text(descarga.chute.toString())),
                  DataCell(
                    Text(
                      '${dateFormat.format(descarga.fechaInicio)}\n${dateFormat.format(descarga.fechaFin)}',
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
