import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

class VolqueteFormPage extends StatefulWidget {
  const VolqueteFormPage({
    super.key,
    this.initial,
    this.initialTipo,
    this.initialEquipo,
  });

  final Volquete? initial;
  final VolqueteTipo? initialTipo;
  final VolqueteEquipo? initialEquipo;

  @override
  State<VolqueteFormPage> createState() => _VolqueteFormPageState();
}

class _VolqueteFormPageState extends State<VolqueteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _llegadaController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  late DateTime _llegadaFrente;
  late VolqueteEstado _estado;
  late VolqueteTipo _tipo;
  late VolqueteEquipo _equipo;
  _VolqueteCatalogItem? _selectedVolquete;
  String? _procedencia;
  int? _chute;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _tipo = initial?.tipo ?? widget.initialTipo ?? VolqueteTipo.carga;
    _equipo = initial?.equipo ?? widget.initialEquipo ?? VolqueteEquipo.cargador;
    _estado = initial?.estado ?? VolqueteEstado.enProceso;
    _llegadaFrente = initial?.llegadaFrente ?? DateTime.now();
    _procedencia = initial?.procedencia;
    _chute = initial?.chute;

    _observacionesController.text = initial?.observaciones ?? '';
    _updateLlegadaController();

    if (initial != null) {
      for (final item in _catalogoVolquetes) {
        if (item.codigo == initial.codigo && item.placa == initial.placa) {
          _selectedVolquete = item;
          break;
        }
      }
      _selectedVolquete ??=
          _VolqueteCatalogItem(codigo: initial.codigo, placa: initial.placa);
    }
  }

  @override
  void dispose() {
    _llegadaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _updateLlegadaController() {
    _llegadaController.text = _dateFormat.format(_llegadaFrente);
  }

  Future<void> _pickLlegada() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _llegadaFrente,
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
      _updateLlegadaController();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final selectedVolquete = _selectedVolquete;
    final procedencia = _procedencia;
    final chute = _chute;

    if (selectedVolquete == null || procedencia == null || chute == null) {
      return;
    }

    final observaciones = _observacionesController.text.trim();
    final List<VolqueteEvento> eventos = widget.initial?.eventos != null
        ? List<VolqueteEvento>.from(widget.initial!.eventos)
        : [
            VolqueteEvento(
              titulo: 'Registro creado',
              descripcion: 'Operación registrada manualmente desde el panel.',
              fecha: DateTime.now(),
            ),
          ];

    final volquete = Volquete(
      id: widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      codigo: selectedVolquete.codigo,
      placa: selectedVolquete.placa,
      operador: 'Turno $procedencia',
      destino: 'Chute $chute',
      fecha: _llegadaFrente,
      estado: _estado,
      tipo: _tipo,
      equipo: _equipo,
      eventos: eventos,
      procedencia: procedencia,
      chute: chute,
      llegadaFrente: _llegadaFrente,
      observaciones: observaciones.isEmpty ? null : observaciones,
      documento: widget.initial?.documento,
      notas: widget.initial?.notas,
      inicioManiobra: widget.initial?.inicioManiobra,
      inicioCarga: widget.initial?.inicioCarga,
      finCarga: widget.initial?.finCarga,
    );

    Navigator.pop(context, volquete);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEditing = widget.initial != null;
    final String estadoLabel =
        _estado == VolqueteEstado.completo ? 'Completo' : 'Incompleto';

    final TextStyle? sectionStyle =
        theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    final ColorScheme colors = theme.colorScheme;
    final Color defaultChipTextColor =
        theme.textTheme.bodyMedium?.color ?? colors.onSurface;
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.primary),
    );

    final List<_VolqueteCatalogItem> catalogItems =
        List<_VolqueteCatalogItem>.from(_catalogoVolquetes);
    if (_selectedVolquete != null && !catalogItems.contains(_selectedVolquete)) {
      catalogItems.add(_selectedVolquete!);
    }


    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar operación' : 'Registrar operación'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Volquete', style: sectionStyle),
                const SizedBox(height: 8),
                DropdownButtonFormField<_VolqueteCatalogItem>(
                  value: _selectedVolquete,
                  decoration: InputDecoration(
                    labelText: 'Selecciona un volquete',
                    border: baseBorder,
                    enabledBorder: baseBorder,
                    focusedBorder: focusedBorder,
                  ),
                  items: catalogItems
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.codigo),
                        ),
                      )
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Selecciona un volquete' : null,
                  onChanged: (value) => setState(() {
                    _selectedVolquete = value;
                  }),
                ),
                const SizedBox(height: 16),
                Text('Maquinaria', style: sectionStyle),
                const SizedBox(height: 8),
                DropdownButtonFormField<VolqueteEquipo>(
                  value: _equipo,
                  decoration: InputDecoration(
                    labelText: 'Selecciona la maquinaria',
                    border: baseBorder,
                    enabledBorder: baseBorder,
                    focusedBorder: focusedBorder,
                  ),
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
                Text('Procedencia', style: sectionStyle),
                const SizedBox(height: 8),
                FormField<String>(
                  initialValue: _procedencia,
                  validator: (value) =>
                      value == null ? 'Selecciona la procedencia' : null,
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _procedenciaOptions.map((option) {
                            final bool selected = field.value == option;
                            return ChoiceChip(
                              label: Text(
                                option,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected
                                      ? colors.onPrimaryContainer
                                      : defaultChipTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: selected,
                              selectedColor: colors.primaryContainer,
                              backgroundColor: colors.surfaceVariant,
                              side: BorderSide(
                                color: selected
                                    ? colors.primary
                                    : colors.outline.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    _procedencia = option;
                                    field.didChange(option);
                                  } else {
                                    _procedencia = null;
                                    field.didChange(null);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text('Chute', style: sectionStyle),
                const SizedBox(height: 8),
                FormField<int>(
                  initialValue: _chute,
                  validator: (value) =>
                      value == null ? 'Selecciona el chute' : null,
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _chuteOptions.map((option) {
                            final bool selected = field.value == option;
                            return ChoiceChip(
                              label: Text(
                                option.toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: selected
                                      ? colors.onPrimaryContainer
                                      : defaultChipTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: selected,
                              selectedColor: colors.primaryContainer,
                              backgroundColor: colors.surfaceVariant,
                              side: BorderSide(
                                color: selected
                                    ? colors.primary
                                    : colors.outline.withOpacity(0.3),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (isSelected) {
                                setState(() {
                                  if (isSelected) {
                                    _chute = option;
                                    field.didChange(option);
                                  } else {
                                    _chute = null;
                                    field.didChange(null);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              field.errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text('Llegada al frente', style: sectionStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _llegadaController,
                  readOnly: true,
                  onTap: _pickLlegada,
                  decoration: InputDecoration(
                    labelText: 'Llegada al frente',
                    border: baseBorder,
                    enabledBorder: baseBorder,
                    focusedBorder: focusedBorder,
                    suffixIcon: const Icon(Icons.event_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Observaciones', style: sectionStyle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _observacionesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Observaciones adicionales',
                    border: baseBorder,
                    enabledBorder: baseBorder,
                    focusedBorder: focusedBorder,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Estado', style: sectionStyle),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Estado de la operación',
                    border: baseBorder,
                    enabledBorder: baseBorder,
                    focusedBorder: baseBorder,
                  ),
                  child: Text(
                    estadoLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
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
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
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
    );
  }
}

class _VolqueteCatalogItem {
  const _VolqueteCatalogItem({required this.codigo, required this.placa});

  final String codigo;
  final String placa;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _VolqueteCatalogItem) return false;
    return codigo == other.codigo && placa == other.placa;
  }

  @override
  int get hashCode => Object.hash(codigo, placa);
}

const List<_VolqueteCatalogItem> _catalogoVolquetes = [
  _VolqueteCatalogItem(codigo: '(V12) Volqu. DJ F2J-854', placa: 'DJ F2J-854'),
  _VolqueteCatalogItem(codigo: '(V10) Volqu. MG B9P-657', placa: 'MG B9P-657'),
  _VolqueteCatalogItem(codigo: '(V05) Volqu. EO X2Q-733', placa: 'EO X2Q-733'),
  _VolqueteCatalogItem(codigo: '(V03) Volqu. GM B7K-757', placa: 'GM B7K-757'),
  _VolqueteCatalogItem(codigo: '(V21) Volqu. DJ F2J-854', placa: 'DJ F2J-854'),
  _VolqueteCatalogItem(codigo: '(V22) Volqu. EO X2Q-733', placa: 'EO X2Q-733'),
  _VolqueteCatalogItem(codigo: '(V23) Volqu. KQ P9J-301', placa: 'KQ P9J-301'),
];

const List<String> _procedenciaOptions = [
  'Beatriz 1',
  'Beatriz 2',
  'Panchita 1',
  'Panchita 2',
  'Panchita 3',
  'Relavado',
];

const List<int> _chuteOptions = [1, 2, 3, 4, 5];
