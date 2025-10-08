import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

class VolqueteFormPage extends StatefulWidget {
  const VolqueteFormPage({
    super.key,
    this.initial,
    this.defaultTipo,
    this.defaultEquipo,
  });

  final Volquete? initial;
  final VolqueteTipo? defaultTipo;
  final VolqueteEquipo? defaultEquipo;

  @override
  State<VolqueteFormPage> createState() => _VolqueteFormPageState();
}

class _VolqueteFormPageState extends State<VolqueteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigoController;
  late final TextEditingController _placaController;
  late final TextEditingController _operadorController;
  late final TextEditingController _destinoController;
  late final TextEditingController _notasController;
  late final TextEditingController _fechaController;
  late DateTime _fecha;
  late VolqueteEstado _estado;
  late VolqueteTipo _tipo;
  late VolqueteEquipo _equipo;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _codigoController = TextEditingController(text: initial?.codigo ?? '');
    _placaController = TextEditingController(text: initial?.placa ?? '');
    _operadorController = TextEditingController(text: initial?.operador ?? '');
    _destinoController = TextEditingController(text: initial?.destino ?? '');
    _notasController = TextEditingController(text: initial?.notas ?? '');
    _fecha = initial?.fecha ?? DateTime.now();
    _estado = initial?.estado ?? VolqueteEstado.enProceso;
    _tipo = initial?.tipo ?? widget.defaultTipo ?? VolqueteTipo.carga;
    _equipo = initial?.equipo ?? widget.defaultEquipo ?? VolqueteEquipo.cargador;
    _fechaController =
        TextEditingController(text: _dateFormat.format(_fecha));
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _placaController.dispose();
    _operadorController.dispose();
    _destinoController.dispose();
    _notasController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    final initialDate = _fecha;
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: initialDate,
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    setState(() {
      _fecha = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _fechaController.text = _dateFormat.format(_fecha);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final eventos = widget.initial?.eventos ??
        [
          VolqueteEvento(
            titulo: 'Registro creado',
            descripcion: 'Ingreso manual desde el panel de control.',
            fecha: DateTime.now(),
          ),
        ];

    final volquete = Volquete(
      id: widget.initial?.id ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
      codigo: _codigoController.text.trim(),
      placa: _placaController.text.trim(),
      operador: _operadorController.text.trim(),
      destino: _destinoController.text.trim(),
      fecha: _fecha,
      estado: _estado,
      tipo: _tipo,
      equipo: _equipo,
      notas: _notasController.text.trim().isEmpty
          ? widget.initial?.notas
          : _notasController.text.trim(),
      documento: widget.initial?.documento,
      eventos: eventos,
    );

    Navigator.pop(context, volquete);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar volquete' : 'Registrar volquete'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código / Alias',
                    hintText: '(V01) Volq. ABC-123',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un código';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _placaController,
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    hintText: 'ABC-123',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la placa';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _operadorController,
                  decoration: const InputDecoration(
                    labelText: 'Operador',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el operador';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _destinoController,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el destino';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaController,
                  readOnly: true,
                  onTap: _selectFecha,
                  decoration: InputDecoration(
                    labelText: 'Fecha y hora',
                    hintText: _dateFormat.format(DateTime.now()),
                    suffixIcon: const Icon(Icons.event_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VolqueteEstado>(
                  value: _estado,
                  decoration: const InputDecoration(labelText: 'Estado'),
                  items: VolqueteEstado.values
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
                const SizedBox(height: 16),
                DropdownButtonFormField<VolqueteTipo>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: VolqueteTipo.values
                      .map(
                        (tipo) => DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _tipo = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<VolqueteEquipo>(
                  value: _equipo,
                  decoration: const InputDecoration(labelText: 'Equipo'),
                  items: VolqueteEquipo.values
                      .map(
                        (equipo) => DropdownMenuItem(
                          value: equipo,
                          child: Text(equipo.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _equipo = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notasController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
