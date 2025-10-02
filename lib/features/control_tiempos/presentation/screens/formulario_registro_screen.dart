import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/models/registro_tiempo.dart';
import 'package:toolmape/features/control_tiempos/presentation/controllers/control_tiempos_controller.dart';
import 'package:toolmape/theme/app_colors.dart';

enum RegistroModo { creacion, edicion }

class FormularioRegistroScreen extends ConsumerStatefulWidget {
  const FormularioRegistroScreen({
    super.key,
    required this.modo,
    this.registro,
    required this.equipoTipo,
    required this.operacion,
  });

  final RegistroModo modo;
  final RegistroTiempo? registro;
  final EquipoTipo equipoTipo;
  final RegistroOperacion operacion;

  @override
  ConsumerState<FormularioRegistroScreen> createState() =>
      _FormularioRegistroScreenState();
}

class _FormularioRegistroScreenState
    extends ConsumerState<FormularioRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  late final TextEditingController _actividadController;
  late final TextEditingController _operadorController;
  late final TextEditingController _observacionesController;
  late final TextEditingController _inicioController;
  late final TextEditingController _finController;
  late final TextEditingController _volqueteLibreController;

  late DateTime _inicio;
  DateTime? _fin;
  late EquipoTipo _equipo;
  late RegistroOperacion _operacion;
  late String? _volqueteSeleccionado;
  late bool _volqueteLibre;
  late List<String> _volqueteOpciones;

  @override
  void initState() {
    super.initState();
    final registro = widget.registro;
    final state = ref.read(controlTiemposControllerProvider);
    _volqueteOpciones = state.registros
        .map((registro) => registro.volquete)
        .toSet()
        .toList()
      ..sort();

    _equipo = registro?.equipo ?? widget.equipoTipo;
    _operacion = registro?.operacion ?? widget.operacion;
    _inicio = registro?.fechaInicio ?? DateTime.now();
    _fin = registro?.fechaFin;
    _volqueteSeleccionado = registro?.volquete;
    _volqueteLibre = _volqueteSeleccionado == null;
    if (!_volqueteLibre &&
        _volqueteSeleccionado != null &&
        !_volqueteOpciones.contains(_volqueteSeleccionado)) {
      _volqueteOpciones.add(_volqueteSeleccionado!);
      _volqueteOpciones.sort();
    }
    if (_volqueteSeleccionado == null && _volqueteOpciones.isNotEmpty) {
      _volqueteSeleccionado = _volqueteOpciones.first;
      _volqueteLibre = false;
    }

    _actividadController = TextEditingController(
      text: registro?.actividades.isNotEmpty == true
          ? registro!.actividades.first.nombre
          : '',
    );
    _operadorController =
        TextEditingController(text: registro?.operador ?? '');
    _observacionesController =
        TextEditingController(text: registro?.observaciones ?? '');
    _inicioController = TextEditingController(text: _dateFormat.format(_inicio));
    _finController = TextEditingController(
      text: _fin == null ? '' : _dateFormat.format(_fin!),
    );
    _volqueteLibreController = TextEditingController(
      text: _volqueteLibre ? registro?.volquete ?? '' : '',
    );
  }

  @override
  void dispose() {
    _actividadController.dispose();
    _operadorController.dispose();
    _observacionesController.dispose();
    _inicioController.dispose();
    _finController.dispose();
    _volqueteLibreController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarInicio() async {
    final seleccionado = await _seleccionarFecha(_inicio);
    if (seleccionado != null) {
      setState(() {
        _inicio = seleccionado;
        _inicioController.text = _dateFormat.format(_inicio);
        if (_fin != null && _fin!.isBefore(_inicio)) {
          _fin = null;
          _finController.clear();
        }
      });
    }
  }

  Future<void> _seleccionarFin() async {
    final base = _fin ?? _inicio;
    final seleccionado = await _seleccionarFecha(base);
    if (seleccionado != null) {
      setState(() {
        _fin = seleccionado;
        _finController.text = _dateFormat.format(_fin!);
      });
    }
  }

  Future<DateTime?> _seleccionarFecha(DateTime referencia) async {
    final date = await showDatePicker(
      context: context,
      initialDate: referencia,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (date == null) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(referencia),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final controlador = ref.read(controlTiemposControllerProvider.notifier);
    final service = controlador.service;

    final volquete = _volqueteLibre
        ? _volqueteLibreController.text.trim()
        : _volqueteSeleccionado ?? '';

    final observaciones = _observacionesController.text.trim().isEmpty
        ? null
        : _observacionesController.text.trim();

    final estado = _fin != null ? RegistroEstado.completo : RegistroEstado.enProceso;

    final actividades = widget.registro?.actividades ??
        <RegistroActividad>[
          RegistroActividad(
            nombre: _actividadController.text.trim(),
            descripcion: 'Registro creado manualmente.',
            fecha: _inicio,
          ),
          if (_fin != null)
            RegistroActividad(
              nombre: 'Cierre de actividad',
              descripcion: 'Finalización registrada desde el formulario.',
              fecha: _fin!,
            ),
        ];

    final nuevo = RegistroTiempo(
      id: widget.registro?.id ?? 'temp',
      volquete: volquete,
      operador: _operadorController.text.trim(),
      documento: widget.registro?.documento,
      equipo: _equipo,
      operacion: _operacion,
      estado: estado,
      fechaInicio: _inicio,
      fechaFin: _fin,
      destino: widget.registro?.destino ?? 'Destino por definir',
      actividades: actividades,
      observaciones: observaciones,
    );

    try {
      if (widget.modo == RegistroModo.creacion) {
        await service.crearRegistro(nuevo);
      } else {
        await service.actualizarRegistro(nuevo);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el registro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.modo == RegistroModo.edicion;
    final titulo = esEdicion ? 'Editar registro' : 'Nuevo registro';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(title: 'Equipo asignado'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _equipo.label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Datos principales'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _volqueteLibre ? '__libre__' : _volqueteSeleccionado,
                dropdownColor: AppColors.surfaceLight,
                decoration: _inputDecoration('Volquete'),
                items: [
                  ..._volqueteOpciones.map(
                    (opcion) => DropdownMenuItem(
                      value: opcion,
                      child: Text(opcion, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: '__libre__',
                    child: Text('Otro…', style: TextStyle(color: Colors.white70)),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    if (value == '__libre__') {
                      _volqueteLibre = true;
                      _volqueteSeleccionado = null;
                    } else {
                      _volqueteLibre = false;
                      _volqueteSeleccionado = value;
                    }
                  });
                },
                validator: (_) {
                  final value = _volqueteLibre
                      ? _volqueteLibreController.text.trim()
                      : _volqueteSeleccionado;
                  if (value == null || value.isEmpty) {
                    return 'Selecciona un volquete';
                  }
                  return null;
                },
              ),
              if (_volqueteLibre) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _volqueteLibreController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Nombre del volquete'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el volquete';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              DropdownButtonFormField<RegistroOperacion>(
                value: _operacion,
                dropdownColor: AppColors.surfaceLight,
                decoration: _inputDecoration('Tipo de operación'),
                items: RegistroOperacion.values
                    .map(
                      (operacion) => DropdownMenuItem(
                        value: operacion,
                        child: Text(
                          operacion.label,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _operacion = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _actividadController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Actividad realizada'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Describe la actividad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _operadorController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Operador responsable'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el operador';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Tiempos registrados'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _inicioController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Inicio'),
                      onTap: _seleccionarInicio,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona el inicio';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _finController,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Fin (opcional)'),
                      onTap: _seleccionarFin,
                      validator: (_) {
                        if (_fin != null && _fin!.isBefore(_inicio)) {
                          return 'Debe ser mayor al inicio';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(title: 'Observaciones'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacionesController,
                style: const TextStyle(color: Colors.white),
                minLines: 3,
                maxLines: 5,
                decoration: _inputDecoration('Detalle adicional'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
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
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
