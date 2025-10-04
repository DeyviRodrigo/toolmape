import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/excavadora_operacion.dart';

class ExcavadoraOperacionFormPage extends StatefulWidget {
  const ExcavadoraOperacionFormPage({super.key, this.initial});

  final ExcavadoraOperacion? initial;

  @override
  State<ExcavadoraOperacionFormPage> createState() =>
      _ExcavadoraOperacionFormPageState();
}

class _ExcavadoraOperacionFormPageState
    extends State<ExcavadoraOperacionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _observacionesController =
      TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  String? _selectedMaquinaria;
  _ActividadOption? _selectedActividad;
  String? _selectedVolquete;
  int? _selectedChute;
  late DateTime _inicio;
  DateTime? _fin;

  @override
  void initState() {
    super.initState();
    _selectedMaquinaria = widget.initial?.maquinaria;
    _selectedActividad = widget.initial == null
        ? null
        : _actividadOptions.firstWhere(
            (element) => element.id == widget.initial!.actividadId,
            orElse: () => _actividadOptions.first,
          );
    _selectedVolquete = widget.initial?.volquete;
    _selectedChute = widget.initial?.chute;
    _inicio = widget.initial?.inicio ?? DateTime.now();
    _fin = widget.initial?.fin;
    _observacionesController.text = widget.initial?.observaciones ?? '';
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  bool get _mostrarCampoFinal => _fin != null;

  String get _estadoLabel =>
      _fin == null ? 'Incompleto' : 'Completo';

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar operación' : 'Nueva operación'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMaquinaria,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Maquinaria *',
                    border: OutlineInputBorder(),
                  ),
                  items: _maquinariaOptions
                      .map(
                        (maquinaria) => DropdownMenuItem<String>(
                          value: maquinaria,
                          child: Text(maquinaria),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Selecciona una maquinaria' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedMaquinaria = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                FormField<int>(
                  initialValue: _selectedChute,
                  validator: (_) =>
                      _selectedChute == null ? 'Selecciona un chute' : null,
                  builder: (state) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chutes',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: List.generate(5, (index) {
                            final chuteNumber = index + 1;
                            final isSelected = _selectedChute == chuteNumber;
                            return ChoiceChip(
                              label: Text('$chuteNumber'),
                              selected: isSelected,
                              selectedColor: colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : null,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedChute = chuteNumber;
                                });
                                state.didChange(chuteNumber);
                              },
                            );
                          }),
                        ),
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<_ActividadOption>(
                  value: _selectedActividad,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Actividad *',
                    border: OutlineInputBorder(),
                  ),
                  items: _actividadOptions
                      .map(
                        (actividad) => DropdownMenuItem<_ActividadOption>(
                          value: actividad,
                          child: Text(actividad.label),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Selecciona una actividad' : null,
                  onChanged: (value) {
                    setState(() {
                      _selectedActividad = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: _selectedVolquete,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Volquete asociado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sin asignar'),
                    ),
                  ]
                      .followedBy(
                        _volqueteOptions.map(
                          (volquete) => DropdownMenuItem<String?>(
                            value: volquete,
                            child: Text(volquete),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedVolquete = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                FormField<DateTime>(
                  initialValue: _inicio,
                  validator: (_) => _inicio == null
                      ? 'Selecciona fecha y hora de inicio'
                      : null,
                  builder: (state) {
                    return GestureDetector(
                      onTap: () async {
                        final selected = await _seleccionarFechaHora(_inicio);
                        if (selected == null) return;
                        setState(() {
                          _inicio = selected;
                        });
                        state.didChange(selected);
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Inicio *',
                          border: const OutlineInputBorder(),
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          errorText: state.errorText,
                        ),
                        child: Text(_dateFormat.format(_inicio)),
                      ),
                    );
                  },
                ),
                if (_mostrarCampoFinal) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    initialValue: _dateFormat.format(_fin!),
                    decoration: const InputDecoration(
                      labelText: 'Final',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  initialValue: _estadoLabel,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _onSubmit,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _seleccionarFechaHora(DateTime base) async {
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      base.second,
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final actividad = _selectedActividad!;
    final observaciones = _observacionesController.text.trim();

    final nuevaOperacion = ExcavadoraOperacion(
      id: widget.initial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      actividad: actividad.label,
      actividadId: actividad.id,
      maquinaria: _selectedMaquinaria!,
      chute: _selectedChute!,
      inicio: _inicio,
      fin: _fin,
      volquete: _selectedVolquete?.isEmpty ?? true
          ? null
          : _selectedVolquete,
      observaciones: observaciones.isEmpty ? null : observaciones,
    );

    Navigator.pop(context, nuevaOperacion);
  }
}

class _ActividadOption {
  const _ActividadOption({required this.id, required this.label});

  final String id;
  final String label;
}

const List<String> _maquinariaOptions = [
  '(E01) Excav. C 340-01',
  '(E02) Excav. CX-02',
  '(E03) Excav. ZX 250',
  '(E04) Excav. 320D',
];

const List<_ActividadOption> _actividadOptions = [
  _ActividadOption(id: 'carguio_gravas', label: 'Carguío de Gravas'),
  _ActividadOption(id: 'carga_mineral', label: 'Carga de Mineral'),
  _ActividadOption(id: 'mov_desmonte', label: 'Movimiento de Desmonte'),
  _ActividadOption(id: 'limpieza_frente', label: 'Limpieza de Frente'),
];

const List<String> _volqueteOptions = [
  '(V07) Volqu. RD F7V-760',
  '(V11) Volqu. CM B7K-757',
  '(V12) Volqu. GQ VQN-840',
  '(V15) Volqu. JAA X3U-843',
];
