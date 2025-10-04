import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/descarga_registro.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/descarga_form_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/descarga_inline_table_page.dart';

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _accentColor = Color(0xFFFF9F1C);
const Color _textSecondary = Color(0xFF9CA3AF);

class DescargaDetailPage extends StatefulWidget {
  const DescargaDetailPage({
    super.key,
    required this.registro,
    required this.registros,
  });

  final DescargaRegistro registro;
  final List<DescargaRegistro> registros;

  @override
  State<DescargaDetailPage> createState() => _DescargaDetailPageState();
}

class _DescargaDetailPageState extends State<DescargaDetailPage> {
  late List<DescargaRegistro> _allRegistros;
  late DescargaRegistro _registroActual;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _allRegistros = _sortByFecha(widget.registros);
    _registroActual = widget.registro;
  }

  List<DescargaRegistro> get _relacionados => _sortByFecha(
        _allRegistros.where((r) => r.volquete == _registroActual.volquete).toList(),
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _sortByFecha(_allRegistros));
        return false;
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          backgroundColor: _backgroundColor,
          foregroundColor: Colors.white,
          title: Text(_registroActual.volquete),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _sortByFecha(_allRegistros)),
          ),
          actions: [
            IconButton(
              tooltip: 'Editar registro',
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoSection(
                  registro: _registroActual,
                  dateFormat: _dateFormat,
                ),
                const SizedBox(height: 24),
                _ActionButtons(onAction: _showActionSnack),
                const SizedBox(height: 24),
                _RelatedTable(
                  registros: _relacionados,
                  dateFormat: _dateFormat,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _openInlineTable,
                    icon: const Icon(Icons.open_in_new, color: _accentColor),
                    label: const Text(
                      'Ver tabla extendida',
                      style: TextStyle(color: _accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openEdit() async {
    final DescargaRegistro? updated = await Navigator.push<DescargaRegistro>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaFormPage(
          mode: DescargaFormMode.edit,
          initial: _registroActual,
        ),
      ),
    );

    if (updated == null) return;

    setState(() {
      final List<DescargaRegistro> updatedList = List<DescargaRegistro>.from(_allRegistros);
      final index = updatedList.indexWhere((element) => element.id == updated.id);
      if (index >= 0) {
        updatedList[index] = updated;
      } else {
        updatedList.add(updated);
      }
      _allRegistros = _sortByFecha(updatedList);
      _registroActual = updated;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga actualizada')),
    );
  }

  void _openInlineTable() async {
    final List<DescargaRegistro>? updated = await Navigator.push<List<DescargaRegistro>>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaInlineTablePage(
          registros: _allRegistros,
          volquete: _registroActual.volquete,
        ),
      ),
    );

    if (updated == null) return;

    setState(() {
      _allRegistros = _sortByFecha(updated);
      _registroActual = _allRegistros.firstWhere(
        (element) => element.id == _registroActual.id,
        orElse: () => _allRegistros.first,
      );
    });
  }

  void _showActionSnack(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(action)),
    );
  }
}

List<DescargaRegistro> _sortByFecha(List<DescargaRegistro> registros) {
  final sorted = List<DescargaRegistro>.from(registros);
  sorted.sort((a, b) => b.llegadaChute.compareTo(a.llegadaChute));
  return sorted;
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.registro, required this.dateFormat});

  final DescargaRegistro registro;
  final DateFormat dateFormat;

  Color get _estadoColor =>
      registro.estado == DescargaEstado.completo ? const Color(0xFF1DB954) : _accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registro.volquete,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registro.volqueteAlias,
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _estadoColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  registro.estado.label,
                  style: TextStyle(
                    color: _estadoColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _InfoChip(label: 'Maquinaria', value: registro.maquinaria),
              _InfoChip(label: 'Procedencia', value: registro.procedencia.isEmpty ? 'Sin definir' : registro.procedencia),
              _InfoChip(label: 'Chute', value: registro.chute.toString()),
            ],
          ),
          const SizedBox(height: 20),
          _InfoTimelineRow(label: 'Llegada a chute', value: dateFormat.format(registro.llegadaChute)),
          if (registro.inicioDescarga != null)
            _InfoTimelineRow(label: 'Inicio descarga', value: dateFormat.format(registro.inicioDescarga!)),
          if (registro.finalDescarga != null)
            _InfoTimelineRow(label: 'Final descarga', value: dateFormat.format(registro.finalDescarga!)),
          if (registro.salidaChute != null)
            _InfoTimelineRow(label: 'Salida de chute', value: dateFormat.format(registro.salidaChute!)),
          if (registro.observaciones != null && registro.observaciones!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Observaciones',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              registro.observaciones!,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(color: _textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoTimelineRow extends StatelessWidget {
  const _InfoTimelineRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(color: _textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onAction});

  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => onAction('Inicio de maniobra activado'),
            child: const Text('Inicio maniobra'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => onAction('Inicio de carga activado'),
            child: const Text('Inicio carga'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => onAction('Final de carga registrado'),
            child: const Text('Final carga'),
          ),
        ),
      ],
    );
  }
}

class _RelatedTable extends StatelessWidget {
  const _RelatedTable({required this.registros, required this.dateFormat});

  final List<DescargaRegistro> registros;
  final DateFormat dateFormat;

  String _format(DateTime? date) => date == null ? '—' : dateFormat.format(date);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.04)),
          headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          dataTextStyle: const TextStyle(color: Colors.white70),
          columns: const [
            DataColumn(label: Text('Volquete')),
            DataColumn(label: Text('Procedencia')),
            DataColumn(label: Text('Chute')),
            DataColumn(label: Text('Llegada a chute')),
            DataColumn(label: Text('Inicio descarga')),
            DataColumn(label: Text('Final descarga')),
            DataColumn(label: Text('Salida de chute')),
            DataColumn(label: Text('Observaciones')),
            DataColumn(label: Text('Estado')),
          ],
          rows: registros
              .map(
                (registro) => DataRow(
                  cells: [
                    DataCell(Text(registro.volquete)),
                    DataCell(Text(registro.procedencia.isEmpty ? '—' : registro.procedencia)),
                    DataCell(Text('Chute ${registro.chute}')),
                    DataCell(Text(_format(registro.llegadaChute))),
                    DataCell(Text(_format(registro.inicioDescarga))),
                    DataCell(Text(_format(registro.finalDescarga))),
                    DataCell(Text(_format(registro.salidaChute))),
                    DataCell(Text(registro.observaciones ?? '—')),
                    DataCell(Text(registro.estado.label)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
