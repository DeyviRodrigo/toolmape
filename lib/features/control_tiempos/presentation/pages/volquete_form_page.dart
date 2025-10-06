import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/theme/control_tiempos_palette.dart';

const String _iconArrowRight = 'assets/icons/arrow_right.svg';
const String _iconTruckEmpty = 'assets/icons/truck_small.svg';
const String _iconTruckLoaded = 'assets/icons/truck_large.svg';
const String _iconEditPen = 'assets/icons/edit_pen.svg';

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
    final ControlTiemposPalette palette = ControlTiemposPalette.of(baseTheme);
    final ThemeData themed = baseTheme.copyWith(
      scaffoldBackgroundColor: palette.background,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: palette.accent,
        secondary: palette.accent,
        surface: palette.surface,
        background: palette.background,
        onSurface: palette.primaryText,
        onPrimary: palette.onAccent,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: palette.primaryText,
        displayColor: palette.primaryText,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: palette.background,
        foregroundColor: palette.primaryText,
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.outline.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.accent, width: 2),
        ),
        labelStyle: TextStyle(color: palette.mutedText),
        hintStyle: TextStyle(color: palette.subtleText),
      ),
    );

    final isEditing = widget.mode == VolqueteFormMode.edit;
    final isQuickAdd = widget.mode == VolqueteFormMode.quickAdd;

    return Theme(
      data: themed,
      child: Scaffold(
        backgroundColor: palette.background,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _EstadoChip(estado: _estado),
                        const SizedBox(height: 16),
                        const Wrap(
                          spacing: 12,
                          children: [
                            _QuickIcon(asset: _iconArrowRight),
                            _QuickIcon(asset: _iconTruckEmpty),
                            _QuickIcon(asset: _iconTruckLoaded),
                            _QuickIcon(asset: _iconEditPen),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  TextFormField(
                    controller: _volqueteController,
                    style: TextStyle(color: palette.primaryText),
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
                    dropdownColor: palette.surface,
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
                                selectedColor: palette.accent,
                                backgroundColor: palette.surface,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? palette.onAccent
                                      : palette.mutedText,
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
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
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
                                selectedColor: palette.accent,
                                backgroundColor: palette.surface,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? palette.onAccent
                                      : palette.mutedText,
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
                    style: TextStyle(color: palette.primaryText),
                    decoration: InputDecoration(
                      labelText: 'Fecha y hora de llegada al frente',
                      suffixIcon: IconButton(
                        onPressed: _selectFecha,
                        icon: Icon(Icons.calendar_today, color: palette.mutedText),
                      ),
                    ),
                    onTap: _selectFecha,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesController,
                    minLines: 3,
                    maxLines: 4,
                    style: TextStyle(color: palette.primaryText),
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
                    dropdownColor: palette.surface,
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
                            foregroundColor: palette.mutedText,
                            side: BorderSide(color: palette.outline.withOpacity(0.5)),
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
                            backgroundColor: palette.accent,
                            foregroundColor: palette.onAccent,
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
  const _QuickIcon({required this.asset, this.size = 22});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = ControlTiemposPalette.of(Theme.of(context));
    return CircleAvatar(
      radius: 22,
      backgroundColor: palette.surface,
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(palette.icon, BlendMode.srcIn),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final palette = ControlTiemposPalette.of(Theme.of(context));
    if (estado == VolqueteEstado.completo) {
      return Text(
        estado.label.substring(0, 1),
        style: TextStyle(
          color: palette.accent,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: palette.accent.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: palette.accent.withOpacity(0.4),
        ),
      ),
      child: Text(
        estado.label,
        style: TextStyle(
          color: palette.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
