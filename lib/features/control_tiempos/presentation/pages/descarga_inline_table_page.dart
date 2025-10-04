import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/descarga_registro.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/descarga_form_page.dart';

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _accentColor = Color(0xFFFF9F1C);

class DescargaInlineTablePage extends StatefulWidget {
  const DescargaInlineTablePage({
    super.key,
    required this.registros,
    required this.volquete,
  });

  final List<DescargaRegistro> registros;
  final String volquete;

  @override
  State<DescargaInlineTablePage> createState() => _DescargaInlineTablePageState();
}

class _DescargaInlineTablePageState extends State<DescargaInlineTablePage> {
  late List<DescargaRegistro> _allRegistros;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    _allRegistros = _sortByFecha(widget.registros);
  }

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
          title: Text('Descargas Volquetes inline'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _sortByFecha(_allRegistros)),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Registros de descargas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: _openAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                        rows: _allRegistros
                            .map(
                              (registro) => DataRow(
                                color: MaterialStateProperty.resolveWith(
                                  (states) {
                                    if (registro.volquete == widget.volquete) {
                                      return _accentColor.withOpacity(0.08);
                                    }
                                    return null;
                                  },
                                ),
                                onSelectChanged: (_) => _openEdit(registro),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _format(DateTime? date) => date == null ? '—' : _dateFormat.format(date);

  Future<void> _openAdd() async {
    final DescargaRegistro? result = await Navigator.push<DescargaRegistro>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaFormPage(
          mode: DescargaFormMode.create,
          initialVolquete: widget.volquete,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _allRegistros = _upsertRegistro(result, _allRegistros);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga registrada')), 
    );
  }

  Future<void> _openEdit(DescargaRegistro registro) async {
    final DescargaRegistro? result = await Navigator.push<DescargaRegistro>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaFormPage(
          mode: DescargaFormMode.edit,
          initial: registro,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _allRegistros = _upsertRegistro(result, _allRegistros);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga actualizada')),
    );
  }

  List<DescargaRegistro> _upsertRegistro(
    DescargaRegistro registro,
    List<DescargaRegistro> registros,
  ) {
    final List<DescargaRegistro> updated = List<DescargaRegistro>.from(registros);
    final index = updated.indexWhere((element) => element.id == registro.id);
    if (index >= 0) {
      updated[index] = registro;
    } else {
      updated.add(registro);
    }
    return _sortByFecha(updated);
  }
}

List<DescargaRegistro> _sortByFecha(List<DescargaRegistro> registros) {
  final sorted = List<DescargaRegistro>.from(registros);
  sorted.sort((a, b) => b.llegadaChute.compareTo(a.llegadaChute));
  return sorted;
}
