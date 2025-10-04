import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

const Color _accentColor = Color(0xFFFF9F1C);
const Color _backgroundColor = Color(0xFF121212);
const Color _surfaceColor = Color(0xFF1E1E1E);
const Color _chipColor = Color(0xFF1C1C1C);

const _iconArrowRight = 'assets/icons/arrow_right.svg';
const _iconTruckEmpty = 'assets/icons/truck_small.svg';
const _iconTruckLoaded = 'assets/icons/truck_large.svg';
const _iconEditPen = 'assets/icons/edit_pen.svg';

const List<String> _procedenciaOptions = [
  'Beatriz 1',
  'Beatriz 2',
  'Beatriz 3',
  'Panchita 1',
  'Panchita 2',
  'Relavado',
];

const List<String> _maquinariaOptions = [
  '(E01) Excav. C 340-01',
  '(E02) Excav. ZX 350',
  '(E03) Carg. AD L150F',
  '(E04) Carg. WA600',
];

enum VolqueteFormMode { create, edit, quickAdd }

class VolqueteFormPage extends StatefulWidget {
  const VolqueteFormPage({
    super.key,
    this.initial,
    this.defaultTipo,
    this.defaultEquipo,
    this.mode = VolqueteFormMode.create,
  });

  final Volquete? initial;
  final VolqueteTipo? defaultTipo;
  final VolqueteEquipo? defaultEquipo;
  final VolqueteFormMode mode;

  @override
  State<VolqueteFormPage> createState() => _VolqueteFormPageState();
}

class _VolqueteFormPageState extends State<VolqueteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _volqueteController;
  late final TextEditingController _observacionesController;
  late final TextEditingController _fechaController;
  late DateTime _llegadaFrente;
  late Set<String> _procedencias;
  late int _selectedChute;
  late VolqueteEstado _estado;
  late VolqueteTipo _tipo;
  late VolqueteEquipo _equipo;
  late String _maquinaria;
  late List<String> _availableMaquinarias;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _volqueteController = TextEditingController(text: initial?.codigo ?? '');
    _observacionesController =
        TextEditingController(text: initial?.notas ?? '');
    _llegadaFrente = initial?.llegadaFrente ?? DateTime.now();
    _procedencias = initial != null
        ? initial.procedencias.toSet()
        : {_procedenciaOptions.first};
    _selectedChute = initial?.chute ?? 1;
    _estado = initial?.estado ?? VolqueteEstado.incompleto;
    _tipo = initial?.tipo ?? widget.defaultTipo ?? VolqueteTipo.carga;
    _equipo = initial?.equipo ?? widget.defaultEquipo ?? VolqueteEquipo.cargador;
    _availableMaquinarias = List<String>.from(_maquinariaOptions);
    _maquinaria = initial?.maquinaria ?? _availableMaquinarias.first;
    if (!_availableMaquinarias.contains(_maquinaria)) {
      _availableMaquinarias.insert(0, _maquinaria);
    }
    _fechaController = TextEditingController(text: _dateFormat.format(_llegadaFrente));
  }

  @override
  void dispose() {
    _volqueteController.dispose();
    _observacionesController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _llegadaFrente,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_llegadaFrente),
    );
    if (pickedTime == null) return;

    setState(() {
      _llegadaFrente = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _fechaController.text = _dateFormat.format(_llegadaFrente);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final observaciones = _observacionesController.text.trim();
    final eventos = widget.initial?.eventos ??
        [
          VolqueteEvento(
            titulo: 'Registro creado',
            descripcion: 'Ingreso desde módulo Control de Tiempos.',
            fecha: DateTime.now(),
          ),
        ];

    final volquete = Volquete(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      codigo: _volqueteController.text.trim(),
      placa: widget.initial?.placa ?? '-',
      operador: _maquinaria,
      destino: _procedencias.isEmpty ? '-' : _procedencias.first,
      fecha: _llegadaFrente,
      estado: _estado,
      tipo: _tipo,
      equipo: _equipo,
      eventos: eventos,
      maquinaria: _maquinaria,
      procedencias: _procedencias.toList(),
      chute: _selectedChute,
      llegadaFrente: _llegadaFrente,
      inicioManiobra: widget.initial?.inicioManiobra,
      inicioCarga: widget.initial?.inicioCarga,
      finCarga: widget.initial?.finCarga,
      descargas: widget.initial?.descargas ?? const <VolqueteDescarga>[],
      documento: widget.initial?.documento,
      notas: observaciones.isEmpty ? widget.initial?.notas : observaciones,
    );

    Navigator.pop(context, volquete);
  }

  void _cancel() {
    Navigator.pop(context);
  }

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
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accentColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white50),
      ),
    );

    final isEditing = widget.mode == VolqueteFormMode.edit;
    final isQuickAdd = widget.mode == VolqueteFormMode.quickAdd;

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: Text(isEditing
              ? 'Editar carga'
              : isQuickAdd
                  ? 'Nueva carga rápida'
                  : 'Añadir nueva carga'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isQuickAdd) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Wrap(
                          spacing: 12,
                          children: [
                            _QuickIcon(path: _iconArrowRight),
                            _QuickIcon(path: _iconTruckEmpty),
                            _QuickIcon(path: _iconTruckLoaded),
                            _QuickIcon(path: _iconEditPen),
                          ],
                        ),
                        _EstadoChip(estado: _estado),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextFormField(
                    controller: _volqueteController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Volquete *',
                      hintText: '(V12) Volq. ABC-123',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa el nombre del volquete';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _maquinaria,
                    dropdownColor: _surfaceColor,
                    decoration: const InputDecoration(
                      labelText: 'Maquinaria',
                    ),
                    items: _availableMaquinarias
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _maquinaria = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _FormSectionLabel('Procedencia'),
                  const SizedBox(height: 12),
                  FormField<Set<String>>(
                    initialValue: _procedencias,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona al menos una procedencia';
                      }
                      return null;
                    },
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _procedenciaOptions.map((option) {
                              final selected = _procedencias.contains(option);
                              return ChoiceChip(
                                label: Text(option),
                                selected: selected,
                                selectedColor: _accentColor,
                                backgroundColor: _chipColor,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.black : Colors.white,
                                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    if (value) {
                                      _procedencias.add(option);
                                    } else {
                                      _procedencias.remove(option);
                                    }
                                  });
                                  state.didChange(_procedencias);
                                },
                              );
                            }).toList(),
                          ),
                          if (state.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                state.errorText!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _FormSectionLabel('Chute'),
                  const SizedBox(height: 12),
                  FormField<int>(
                    initialValue: _selectedChute,
                    builder: (state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            children: List.generate(5, (index) => index + 1).map((chute) {
                              final selected = _selectedChute == chute;
                              return ChoiceChip(
                                label: Text('$chute'),
                                selected: selected,
                                selectedColor: _accentColor,
                                backgroundColor: _chipColor,
                                labelStyle: TextStyle(
                                  color: selected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedChute = chute;
                                  });
                                  state.didChange(_selectedChute);
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _fechaController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Fecha y hora de llegada al frente',
                      suffixIcon: IconButton(
                        onPressed: _selectFecha,
                        icon: const Icon(Icons.calendar_today, color: Colors.white70),
                      ),
                    ),
                    onTap: _selectFecha,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesController,
                    minLines: 3,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<VolqueteEstado>(
                    value: _estado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                    ),
                    dropdownColor: _surfaceColor,
                    onChanged: isEditing
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _estado = value;
                            });
                          },
                    items: VolqueteEstado.values
                        .map(
                          (estado) => DropdownMenuItem<VolqueteEstado>(
                            value: estado,
                            child: Text(estado.label),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
}

class _FormSectionLabel extends StatelessWidget {
  const _FormSectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
    );
  }
}

class _QuickIcon extends StatelessWidget {
  const _QuickIcon({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: _chipColor,
      child: SvgPicture.asset(
        path,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final bool completo = estado == VolqueteEstado.completo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: completo ? const Color(0xFF1B5E20) : _accentColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: (completo ? const Color(0xFFBBF7D0) : _accentColor).withOpacity(0.4),
        ),
      ),
      child: Text(
        estado.label,
        style: TextStyle(
          color: completo ? const Color(0xFFBBF7D0) : _accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
