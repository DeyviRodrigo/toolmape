import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/descarga_registro.dart';

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _accentColor = Color(0xFFFF9F1C);
const Color _textSecondary = Color(0xFF9CA3AF);

enum DescargaFormMode { create, edit }

class DescargaFormPage extends StatefulWidget {
  const DescargaFormPage({
    super.key,
    required this.mode,
    this.initial,
    this.initialVolquete,
    this.lockVolquete = false,
  });

  final DescargaFormMode mode;
  final DescargaRegistro? initial;
  final String? initialVolquete;
  final bool lockVolquete;

  bool get isEdit => mode == DescargaFormMode.edit;

  @override
  State<DescargaFormPage> createState() => _DescargaFormPageState();
}

class _DescargaFormPageState extends State<DescargaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _volqueteController;
  late final TextEditingController _procedenciaController;
  late final TextEditingController _observacionesController;
  late final TextEditingController _llegadaController;
  late final TextEditingController _inicioController;
  late final TextEditingController _finalController;
  late final TextEditingController _salidaController;

  late int _selectedChute;
  late DateTime _llegadaChute;
  DateTime? _inicioDescarga;
  DateTime? _finalDescarga;
  DateTime? _salidaChute;
  late DescargaEstado _estado;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _volqueteController = TextEditingController(
      text: initial?.volquete ?? widget.initialVolquete ?? '',
    );
    _procedenciaController = TextEditingController(
      text: initial?.procedencia ?? '',
    );
    _observacionesController = TextEditingController(
      text: initial?.observaciones ?? '',
    );
    _selectedChute = initial?.chute ?? 1;
    _llegadaChute = initial?.llegadaChute ?? DateTime.now();
    _inicioDescarga = initial?.inicioDescarga;
    _finalDescarga = initial?.finalDescarga;
    _salidaChute = initial?.salidaChute;
    _estado = initial?.estado ?? DescargaEstado.incompleto;

    _llegadaController = TextEditingController(text: _dateFormat.format(_llegadaChute));
    _inicioController = TextEditingController(
      text: _inicioDescarga != null ? _dateFormat.format(_inicioDescarga!) : '',
    );
    _finalController = TextEditingController(
      text: _finalDescarga != null ? _dateFormat.format(_finalDescarga!) : '',
    );
    _salidaController = TextEditingController(
      text: _salidaChute != null ? _dateFormat.format(_salidaChute!) : '',
    );
  }

  @override
  void dispose() {
    _volqueteController.dispose();
    _procedenciaController.dispose();
    _observacionesController.dispose();
    _llegadaController.dispose();
    _inicioController.dispose();
    _finalController.dispose();
    _salidaController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime({
    required DateTime initialDate,
    required ValueChanged<DateTime> onChanged,
    required TextEditingController controller,
  }) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    final DateTime result = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    onChanged(result);
    controller.text = _dateFormat.format(result);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final observaciones = _observacionesController.text.trim();
    final registro = DescargaRegistro(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      volquete: _volqueteController.text.trim(),
      volqueteAlias: _volqueteController.text.trim(),
      maquinaria: widget.initial?.maquinaria ?? 'Maquinaria sin asignar',
      procedencia: _procedenciaController.text.trim(),
      chute: _selectedChute,
      llegadaChute: _llegadaChute,
      inicioDescarga: _inicioDescarga,
      finalDescarga: _finalDescarga,
      salidaChute: _salidaChute,
      observaciones: observaciones.isEmpty ? null : observaciones,
      estado: _estado,
    );

    Navigator.pop(context, registro);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.isEdit;
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Editar descarga' : 'Registrar descarga'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel('Volquete *'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _volqueteController,
                        readOnly: widget.lockVolquete,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Ej. (V09) Volqu. JAA X3U-843'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el volquete';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Procedencia'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _procedenciaController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Ubicación o frente de trabajo'),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Chute'),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final chute = index + 1;
                          final bool isSelected = _selectedChute == chute;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 6,
                                right: index == 4 ? 0 : 6,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedChute = chute;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? _accentColor : Colors.white.withOpacity(0.04),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      chute.toString(),
                                      style: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Llegada a chute'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _llegadaController,
                        readOnly: true,
                        style: const TextStyle(color: Colors.white),
                        onTap: () async {
                          await _selectDateTime(
                            initialDate: _llegadaChute,
                            onChanged: (value) => setState(() => _llegadaChute = value),
                            controller: _llegadaController,
                          );
                        },
                        decoration: _inputDecoration('Selecciona fecha y hora'),
                      ),
                      if (isEdit) ...[
                        const SizedBox(height: 16),
                        _FieldLabel('Inicio descarga'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _inicioController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          onTap: () async {
                            await _selectDateTime(
                              initialDate: _inicioDescarga ?? _llegadaChute,
                              onChanged: (value) => setState(() => _inicioDescarga = value),
                              controller: _inicioController,
                            );
                          },
                          decoration: _inputDecoration('Selecciona fecha y hora'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Final descarga'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _finalController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          onTap: () async {
                            await _selectDateTime(
                              initialDate: _finalDescarga ?? _inicioDescarga ?? _llegadaChute,
                              onChanged: (value) => setState(() => _finalDescarga = value),
                              controller: _finalController,
                            );
                          },
                          decoration: _inputDecoration('Selecciona fecha y hora'),
                        ),
                        const SizedBox(height: 16),
                        _FieldLabel('Salida de chute'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _salidaController,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          onTap: () async {
                            await _selectDateTime(
                              initialDate: _salidaChute ?? _finalDescarga ?? _llegadaChute,
                              onChanged: (value) => setState(() => _salidaChute = value),
                              controller: _salidaController,
                            );
                          },
                          decoration: _inputDecoration('Selecciona fecha y hora'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _FieldLabel('Observaciones'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _observacionesController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Notas relevantes de la maniobra'),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Estado'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DescargaEstado>(
                        value: _estado,
                        onChanged: widget.isEdit ? null : (value) {
                          if (value != null) {
                            setState(() {
                              _estado = value;
                            });
                          }
                        },
                        items: DescargaEstado.values
                            .map(
                              (estado) => DropdownMenuItem<DescargaEstado>(
                                value: estado,
                                child: Text(estado.label),
                              ),
                            )
                            .toList(),
                        dropdownColor: _cardColor,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Selecciona el estado'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: _textSecondary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _submit,
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textSecondary),
      filled: true,
      fillColor: Colors.white.withOpacity(0.04),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentColor),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
