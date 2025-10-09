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
  late final TextEditingController _customProcedenciaController;
  late final TextEditingController _notasController;
  late final TextEditingController _fechaController;
  late DateTime _fecha;
  late VolqueteEstado _estado;
  late VolqueteTipo _tipo;
  late VolqueteEquipo _equipo;

  static const List<String> _baseProcedencias = [
    'Beatriz 1',
    'Beatriz 2',
    'Beatriz 3',
    'Panchita 1',
    'Panchita 2',
    'Panchita 3',
    'Relavado',
    'Otro',
  ];
  static const List<int> _chuteOptions = [1, 2, 3, 4, 5];
  static final RegExp _chuteRegExp = RegExp(r'Chute (\\d+)');

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final DateFormat _eventFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  late String _selectedProcedencia;
  String _customProcedencia = '';
  int? _selectedChute;

  final Map<String, DateTime?> _eventoFechas = {};
  final Map<String, TextEditingController> _eventoControllers = {};

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _codigoController = TextEditingController(text: initial?.codigo ?? '');
    _placaController = TextEditingController(text: initial?.placa ?? '');
    _operadorController = TextEditingController(text: initial?.operador ?? '');
    _notasController = TextEditingController(text: initial?.notas ?? '');
    _fecha = initial?.fecha ?? DateTime.now();
    _estado = initial?.estado ?? VolqueteEstado.enProceso;
    _tipo = initial?.tipo ?? widget.defaultTipo ?? VolqueteTipo.carga;
    _equipo = initial?.equipo ?? widget.defaultEquipo ?? VolqueteEquipo.cargador;
    _fechaController = TextEditingController(text: _dateFormat.format(_fecha));

    final initialProcedencia = _extractProcedencia(initial?.destino);
    if (initialProcedencia != null &&
        _baseProcedencias.contains(initialProcedencia)) {
      _selectedProcedencia = initialProcedencia;
    } else if (initialProcedencia != null && initialProcedencia.isNotEmpty) {
      _selectedProcedencia = 'Otro';
      _customProcedencia = initialProcedencia;
    } else {
      _selectedProcedencia = _baseProcedencias.first;
    }

    _selectedChute = _extractChute(initial?.destino);

    _customProcedenciaController =
        TextEditingController(text: _customProcedencia);

    _configureEventoControllers(initialSync: true);
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _placaController.dispose();
    _operadorController.dispose();
    _customProcedenciaController.dispose();
    _notasController.dispose();
    _fechaController.dispose();
    for (final controller in _eventoControllers.values) {
      controller.dispose();
    }
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

    final procedencia = _resolveProcedencia();
    final destino = _composeDestino(procedencia);
    final observaciones = _notasController.text.trim();
    final eventos = _buildEventos();

    final volquete = Volquete(
      id: widget.initial?.id ?? 'local-${DateTime.now().millisecondsSinceEpoch}',
      codigo: _codigoController.text.trim(),
      placa: _placaController.text.trim(),
      operador: _operadorController.text.trim(),
      destino: destino,
      fecha: _fecha,
      estado: _estado,
      tipo: _tipo,
      equipo: _equipo,
      notas: observaciones.isEmpty ? null : observaciones,
      documento: widget.initial?.documento,
      eventos: eventos,
    );

    Navigator.pop(context, volquete);
  }

  String _resolveProcedencia() {
    if (_selectedProcedencia == 'Otro') {
      return _customProcedencia.trim().isEmpty
          ? 'Sin procedencia'
          : _customProcedencia.trim();
    }
    return _selectedProcedencia;
  }

  String _composeDestino(String procedencia) {
    if (_selectedChute == null) return procedencia;
    return '$procedencia - Chute ${_selectedChute!}';
  }

  String? _extractProcedencia(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final chuteMatch = _chuteRegExp.firstMatch(raw);
    if (chuteMatch == null) return raw.trim();
    final chuteText = chuteMatch.group(0);
    return raw.replaceAll(' - $chuteText', '').trim();
  }

  int? _extractChute(String? raw) {
    if (raw == null) return null;
    final match = _chuteRegExp.firstMatch(raw);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  void _configureEventoControllers({bool initialSync = false}) {
    final expected = _expectedEventos(_tipo);
    final expectedTitles = expected.map((event) => event.titulo).toSet();

    final keysToRemove = _eventoControllers.keys
        .where((key) => !expectedTitles.contains(key))
        .toList();
    for (final key in keysToRemove) {
      _eventoControllers.remove(key)?.dispose();
      _eventoFechas.remove(key);
    }

    for (final event in expected) {
      if (_eventoControllers.containsKey(event.titulo)) {
        final fecha = _eventoFechas[event.titulo];
        _eventoControllers[event.titulo]!.text =
            fecha != null ? _eventFormat.format(fecha) : '';
        continue;
      }

      DateTime? fecha;
      if (initialSync) {
        fecha = _initialEvento(event.titulo)?.fecha;
      }
      _eventoFechas[event.titulo] = fecha;
      _eventoControllers[event.titulo] = TextEditingController(
        text: fecha != null ? _eventFormat.format(fecha) : '',
      );
    }
  }

  Future<void> _selectEventoFecha(_EventoField field) async {
    final initialDate = _eventoFechas[field.titulo] ?? _fecha;
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: initialDate,
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (pickedTime == null) return;

    setState(() {
      final resolvedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _eventoFechas[field.titulo] = resolvedDate;
      _eventoControllers[field.titulo]!.text =
          _eventFormat.format(resolvedDate);
    });
  }

  VolqueteEvento? _initialEvento(String titulo) {
    final initialEventos = widget.initial?.eventos ?? const [];
    for (final evento in initialEventos) {
      if (evento.titulo.toLowerCase() == titulo.toLowerCase()) {
        return evento;
      }
    }
    return null;
  }

  List<VolqueteEvento> _buildEventos() {
    final initialEventos = widget.initial?.eventos ??
        [
          VolqueteEvento(
            titulo: 'Registro creado',
            descripcion: 'Ingreso manual desde el panel de control.',
            fecha: DateTime.now(),
          ),
        ];

    final Map<String, VolqueteEvento> eventosPorTitulo = {
      for (final evento in initialEventos)
        evento.titulo.toLowerCase(): evento,
    };

    for (final entry in _eventoFechas.entries) {
      final titulo = entry.key;
      final fecha = entry.value;
      final key = titulo.toLowerCase();

      if (fecha == null) {
        eventosPorTitulo.remove(key);
        continue;
      }

      final anterior = eventosPorTitulo[key];
      eventosPorTitulo[key] = VolqueteEvento(
        titulo: titulo,
        descripcion:
            anterior?.descripcion ?? _defaultDescripcion(titulo),
        fecha: fecha,
      );
    }

    final eventos = eventosPorTitulo.values.toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    return eventos;
  }

  List<_EventoField> _expectedEventos(VolqueteTipo tipo) {
    switch (tipo) {
      case VolqueteTipo.carga:
        return const [
          _EventoField(
            titulo: 'Inicio de maniobra',
            label: 'Inicio maniobra',
            descripcion: 'Registro del inicio de maniobra de carga.',
          ),
          _EventoField(
            titulo: 'Inicio de carga',
            label: 'Inicio carga',
            descripcion: 'Registro del inicio de carga.',
          ),
          _EventoField(
            titulo: 'Final de carga',
            label: 'Fin de carga',
            descripcion: 'Registro del fin de carga.',
          ),
        ];
      case VolqueteTipo.descarga:
        return const [
          _EventoField(
            titulo: 'Llegada al chute',
            label: 'Llegada al chute',
            descripcion: 'Registro de llegada al chute.',
          ),
          _EventoField(
            titulo: 'Fin de descarga',
            label: 'Fin de descarga',
            descripcion: 'Registro de finalización de descarga.',
          ),
          _EventoField(
            titulo: 'Maniobra de salida',
            label: 'Maniobra de salida',
            descripcion: 'Registro de la maniobra de salida.',
          ),
        ];
    }
  }

  String _defaultDescripcion(String titulo) {
    switch (titulo.toLowerCase()) {
      case 'inicio de maniobra':
        return 'Inicio de maniobra registrado manualmente.';
      case 'inicio de carga':
        return 'Inicio de carga registrado manualmente.';
      case 'final de carga':
        return 'Final de carga registrado manualmente.';
      case 'llegada al chute':
        return 'Llegada al chute registrada manualmente.';
      case 'fin de descarga':
        return 'Fin de descarga registrado manualmente.';
      case 'maniobra de salida':
        return 'Maniobra de salida registrada manualmente.';
      default:
        return 'Evento actualizado manualmente.';
    }
  }

  Widget _buildEventoField(_EventoField field) {
    final controller = _eventoControllers[field.titulo]!;
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectEventoFecha(field),
      decoration: InputDecoration(
        labelText: field.label,
        suffixIcon: controller.text.isEmpty
            ? const Icon(Icons.event_outlined)
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _eventoFechas[field.titulo] = null;
                    controller.clear();
                  });
                },
              ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final chipShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final eventoFields =
        _isEditing ? _expectedEventos(_tipo) : const <_EventoField>[];

    Widget buildSectionTitle(String text) {
      return Text(text, style: labelStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _codigoController,
          decoration: const InputDecoration(
            labelText: 'Volquete *',
            hintText: '(V01) Volq. ABC-123',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ingresa un volquete';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<VolqueteEquipo>(
          value: _equipo,
          decoration: const InputDecoration(labelText: 'Maquinaria'),
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
        const SizedBox(height: 24),
        buildSectionTitle('Procedencia'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in _baseProcedencias)
              ChoiceChip(
                label: Text(option == 'Otro' ? 'Otro destino' : option),
                selected: _selectedProcedencia == option,
                onSelected: (_) {
                  setState(() {
                    _selectedProcedencia = option;
                    if (option != 'Otro') {
                      _customProcedencia = '';
                      _customProcedenciaController.clear();
                    } else {
                      _customProcedenciaController.text = _customProcedencia;
                    }
                  });
                },
                shape: chipShape,
              ),
          ],
        ),
        if (_selectedProcedencia == 'Otro') ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: _customProcedenciaController,
            decoration: const InputDecoration(
              labelText: 'Procedencia personalizada',
            ),
            onChanged: (value) => _customProcedencia = value,
            validator: (value) {
              if (_selectedProcedencia != 'Otro') return null;
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa la procedencia';
              }
              return null;
            },
          ),
        ],
        const SizedBox(height: 24),
        buildSectionTitle('Chute'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Sin chute'),
              selected: _selectedChute == null,
              onSelected: (_) {
                setState(() => _selectedChute = null);
              },
              shape: chipShape,
            ),
            for (final chute in _chuteOptions)
              ChoiceChip(
                label: Text(chute.toString()),
                selected: _selectedChute == chute,
                onSelected: (_) {
                  setState(() => _selectedChute = chute);
                },
                shape: chipShape,
              ),
          ],
        ),
        const SizedBox(height: 24),
        buildSectionTitle('Llegada a frente'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fechaController,
          readOnly: true,
          onTap: _selectFecha,
          decoration: InputDecoration(
            hintText: _dateFormat.format(DateTime.now()),
            suffixIcon: const Icon(Icons.event_outlined),
          ),
        ),
        const SizedBox(height: 24),
        if (eventoFields.isNotEmpty) ...[
          buildSectionTitle('Eventos de la operación'),
          const SizedBox(height: 8),
          for (var i = 0; i < eventoFields.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == eventoFields.length - 1 ? 0 : 16),
              child: _buildEventoField(eventoFields[i]),
            ),
          const SizedBox(height: 24),
        ],
        buildSectionTitle('Observaciones'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notasController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Añade comentarios u observaciones',
          ),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.symmetric(vertical: 8),
          initiallyExpanded: _isEditing,
          title: Text(
            'Configuración avanzada',
            style: labelStyle,
          ),
          children: [
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
                setState(() {
                  _tipo = value;
                  _configureEventoControllers();
                });
              },
            ),
          ],
        ),
      ],
    );
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
            child: _buildFormContent(context),
          ),
        ),
      ),
    );
  }

}

class _EventoField {
  const _EventoField({
    required this.titulo,
    required this.label,
    required this.descripcion,
  });

  final String titulo;
  final String label;
  final String descripcion;
}
