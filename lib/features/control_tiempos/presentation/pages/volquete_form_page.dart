import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/operacion.dart';
import 'package:toolmape/features/control_tiempos/presentation/widgets/toolmape_header.dart';

const _backgroundColor = Color(0xFF0B1220);
const _cardColor = Color(0xFF111827);
const _accentColor = Color(0xFFF59E0B);

class OperacionFormPage extends StatefulWidget {
  const OperacionFormPage({super.key, this.initial});

  final Operacion? initial;

  @override
  State<OperacionFormPage> createState() => _OperacionFormPageState();
}

class _OperacionFormPageState extends State<OperacionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('d/M/yyyy HH:mm:ss');

  late TextEditingController _actividadController;
  late TextEditingController _volqueteController;
  late TextEditingController _inicioController;
  late TextEditingController _finController;
  late TextEditingController _observacionesController;

  late String _maquinaria;
  late int _chute;
  late DateTime _inicio;
  DateTime? _fin;
  late EstadoOperacion _estado;

  bool get _isEditing => widget.initial != null;

  static const List<String> _maquinarias = [
    '(E01) Excav. C 340-01',
    '(E02) Excav. C 340-02',
    '(E03) Excav. C 340-03',
    '(E04) Excav. C 340-04',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _maquinaria = initial?.maquinaria ?? _maquinarias.first;
    _chute = initial?.chute ?? 1;
    _inicio = initial?.inicio ?? DateTime.now();
    _fin = initial?.fin;
    _estado = initial?.estado ?? EstadoOperacion.incompleto;
    _actividadController = TextEditingController(text: initial?.actividad ?? '');
    _volqueteController = TextEditingController(text: initial?.volquete ?? '');
    _inicioController =
        TextEditingController(text: _dateFormat.format(_inicio));
    _finController = TextEditingController(
      text: _fin != null ? _dateFormat.format(_fin!) : '',
    );
    _observacionesController =
        TextEditingController(text: initial?.observaciones ?? '');
  }

  @override
  void dispose() {
    _actividadController.dispose();
    _volqueteController.dispose();
    _inicioController.dispose();
    _finController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _selectInicio() async {
    final picked = await _pickDateTime(_inicio);
    if (picked != null) {
      setState(() {
        _inicio = picked;
        _inicioController.text = _dateFormat.format(_inicio);
      });
    }
  }

  Future<void> _selectFin() async {
    final picked = await _pickDateTime(_fin ?? DateTime.now());
    if (picked != null) {
      setState(() {
        _fin = picked;
        _finController.text = _dateFormat.format(_fin!);
      });
    }
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    FocusScope.of(context).unfocus();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final actividad = _actividadController.text.trim();
    final volquete = _volqueteController.text.trim();
    final observaciones = _observacionesController.text.trim();

    final operacion = Operacion(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      maquinaria: _maquinaria,
      chute: _chute,
      actividad: actividad,
      inicio: _inicio,
      fin: _finController.text.trim().isEmpty ? null : _fin,
      volquete: volquete.isEmpty ? null : volquete,
      observaciones: observaciones.isEmpty ? null : observaciones,
      estado: _estado,
    );

    Navigator.pop(context, operacion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: const ToolmapeHeader(),
      drawer: const Drawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(text: _isEditing ? 'Editar operación' : 'Nueva operación'),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _maquinaria,
                    decoration: _inputDecoration('Maquinaria*'),
                    dropdownColor: _cardColor,
                    items: _maquinarias
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _maquinaria = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chutes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: List.generate(5, (index) {
                      final chute = index + 1;
                      final isSelected = chute == _chute;
                      return ChoiceChip(
                        label: Text(chute.toString()),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: _accentColor,
                        backgroundColor: const Color(0xFF1F2937),
                        onSelected: (_) => setState(() => _chute = chute),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _actividadController,
                    decoration: _inputDecoration('Actividad*'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa la actividad';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _volqueteController,
                    decoration: _inputDecoration('Volquete (si aplica)'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _inicioController,
                    readOnly: true,
                    onTap: _selectInicio,
                    decoration: _inputDecoration('Inicio*').copyWith(
                      suffixIcon: const Icon(Icons.calendar_month, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _finController,
                    readOnly: true,
                    onTap: _selectFin,
                    decoration: _inputDecoration('Final').copyWith(
                      suffixIcon: const Icon(Icons.calendar_month, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesController,
                    maxLines: 3,
                    decoration: _inputDecoration('Observaciones'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EstadoOperacion>(
                    value: _estado,
                    decoration: _inputDecoration('Estado').copyWith(
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    ),
                    dropdownColor: _cardColor,
                    items: EstadoOperacion.values
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _estado = value);
                    },
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1F2937),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}
