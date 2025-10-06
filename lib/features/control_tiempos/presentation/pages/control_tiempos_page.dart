import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_info_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/theme/control_tiempos_palette.dart';

const String _iconArrowRight = 'assets/icons/arrow_right.svg';
const String _iconTruckEmpty = 'assets/icons/truck_small.svg';
const String _iconTruckLoaded = 'assets/icons/truck_large.svg';
const String _iconEditPen = 'assets/icons/edit_pen.svg';

const _iconLoaderTab = 'assets/icons/loader_tab.svg';
const _iconExcavatorTab = 'assets/icons/excavator_tab.svg';
const _iconExcavatorCarga = 'assets/icons/excavator_carga.svg';
const _iconExcavatorDescarga = 'assets/icons/excavator_descarga.svg';

/// Página: ControlTiemposPage - espacio para gestionar actividades y tiempos.
class ControlTiemposPage extends StatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  State<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

class _ControlTiemposPageState extends State<ControlTiemposPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  late List<Volquete> _volquetes;
  int _selectedBottomIndex = 0;
  String _searchTerm = '';
  Timer? _debounce;
  bool _isSelectionMode = false;
  final Set<String> _selectedVolquetes = <String>{};

  VolqueteEquipo get _selectedEquipo =>
      _tabController.index == 0 ? VolqueteEquipo.cargador : VolqueteEquipo.excavadora;

  VolqueteTipo get _selectedTipo =>
      _selectedBottomIndex == 0 ? VolqueteTipo.carga : VolqueteTipo.descarga;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _volquetes = List<Volquete>.from(_initialVolquetes);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        _searchTerm = value.trim().toLowerCase();
      });
    });
  }

  Future<void> _openForm({
    Volquete? initial,
    VolqueteFormMode mode = VolqueteFormMode.create,
  }) async {
    final result = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(
          initial: initial,
          defaultTipo: initial?.tipo ?? _selectedTipo,
          defaultEquipo: initial?.equipo ?? _selectedEquipo,
          mode: mode,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      final existingIndex = _volquetes.indexWhere((v) => v.id == result.id);
      if (existingIndex >= 0) {
        _volquetes[existingIndex] = result;
      } else {
        _volquetes = [result, ..._volquetes];
      }
      _normalizeSelection();
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(initial == null
            ? 'Nueva carga registrada correctamente'
            : 'Carga actualizada correctamente'),
      ),
    );
  }

  Future<void> _openDetail(Volquete volquete) async {
    final result = await Navigator.push<VolqueteDetailResult>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteDetailPage(volquete: volquete),
      ),
    );

    if (result == null) return;

    if (result.deletedVolqueteId != null) {
      setState(() {
        _volquetes =
            _volquetes.where((v) => v.id != result.deletedVolqueteId).toList();
        _normalizeSelection();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro eliminado.')),
      );
      return;
    }

    if (result.updatedVolquete != null) {
      setState(() {
        final index =
            _volquetes.indexWhere((v) => v.id == result.updatedVolquete!.id);
        if (index >= 0) {
          _volquetes[index] = result.updatedVolquete!;
        }
        _normalizeSelection();
      });
    }

    if (result.createdVolquete != null) {
      setState(() {
        _volquetes = [result.createdVolquete!, ..._volquetes];
        _normalizeSelection();
      });
    }

    if (!mounted) return;
    if (result.updatedVolquete != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro actualizado.')),
      );
    } else if (result.createdVolquete != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nueva carga añadida al listado.')),
      );
    }
  }

  void _openVolqueteInfo(Volquete volquete) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteInfoPage(volquete: volquete),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _refreshList() {
    setState(() {
      _volquetes = [..._volquetes]..sort((a, b) => b.fecha.compareTo(a.fecha));
      _normalizeSelection();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Listado actualizado.')),
    );
  }

  void _registerFinCargaFromList(Volquete volquete) {
    final DateTime now = DateTime.now();
    final Volquete updated = volquete.copyWith(
      finCarga: now,
      estado: VolqueteEstado.completo,
      eventos: [
        ...volquete.eventos,
        VolqueteEvento(
          titulo: 'Fin de carga',
          descripcion: 'Confirmado desde acciones rápidas.',
          fecha: now,
          icon: VolqueteEventoIcon.truckLoaded,
        ),
      ],
    );

    setState(() {
      _volquetes = [
        for (final item in _volquetes)
          if (item.id == updated.id) updated else item,
      ];
      _normalizeSelection();
    });

    _showSnack('Fin de carga registrado para ${volquete.codigo}.');
  }

  void _normalizeSelection() {
    _selectedVolquetes
        .removeWhere((id) => !_volquetes.any((volquete) => volquete.id == id));
  }

  void _toggleSelectionMode() {
    setState(() {
      if (_isSelectionMode) {
        _isSelectionMode = false;
        _selectedVolquetes.clear();
      } else {
        _isSelectionMode = true;
      }
    });
  }

  void _exitSelectionMode() {
    if (!_isSelectionMode) return;
    setState(() {
      _isSelectionMode = false;
      _selectedVolquetes.clear();
    });
  }

  void _toggleVolqueteSelection(Volquete volquete) {
    setState(() {
      if (_selectedVolquetes.contains(volquete.id)) {
        _selectedVolquetes.remove(volquete.id);
      } else {
        _selectedVolquetes.add(volquete.id);
      }
    });
  }

  void _handleVolqueteTap(Volquete volquete) {
    if (_isSelectionMode) {
      _toggleVolqueteSelection(volquete);
    } else {
      _openDetail(volquete);
    }
  }

  void _handleVolqueteLongPress(Volquete volquete) {
    if (_isSelectionMode) {
      _toggleVolqueteSelection(volquete);
      return;
    }

    setState(() {
      _isSelectionMode = true;
      _selectedVolquetes
        ..clear()
        ..add(volquete.id);
    });
  }

  void _markSelectedAsComplete() {
    if (_selectedVolquetes.isEmpty) return;

    final DateTime now = DateTime.now();
    setState(() {
      _volquetes = [
        for (final volquete in _volquetes)
          if (_selectedVolquetes.contains(volquete.id))
            volquete.copyWith(
              finCarga: now,
              estado: VolqueteEstado.completo,
              eventos: [
                ...volquete.eventos,
                if (!volquete.eventos.any(
                  (event) =>
                      event.icon == VolqueteEventoIcon.truckLoaded &&
                      event.titulo == 'Fin de carga',
                ))
                  VolqueteEvento(
                    titulo: 'Fin de carga',
                    descripcion: 'Actualizado desde selección múltiple.',
                    fecha: now,
                    icon: VolqueteEventoIcon.truckLoaded,
                  ),
              ],
            )
          else
            volquete,
      ];
      _normalizeSelection();
    });

    final int count = _selectedVolquetes.length;
    _exitSelectionMode();
    _showSnack(
      count == 1
          ? 'Se marcó 1 registro como completo.'
          : 'Se marcaron $count registros como completos.',
    );
  }

  void _clearSelection() {
    if (_selectedVolquetes.isEmpty) return;
    setState(() {
      _selectedVolquetes.clear();
    });
  }

  List<Volquete> get _filteredVolquetes {
    final filtered = _volquetes.where((volquete) {
      if (volquete.equipo != _selectedEquipo) return false;
      if (volquete.tipo != _selectedTipo) return false;
      if (_searchTerm.isEmpty) return true;

      final term = _searchTerm;
      final procedencias = volquete.procedencias.join(' ').toLowerCase();
      return volquete.codigo.toLowerCase().contains(term) ||
          volquete.maquinaria.toLowerCase().contains(term) ||
          procedencias.contains(term);
    }).toList();

    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    return filtered;
  }

  InputDecoration _searchDecoration({
    required Color fillColor,
    required Color borderColor,
    required Color focusBorderColor,
    required Color iconColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      hintText: 'Buscar volquete…',
      prefixIcon: Icon(Icons.search, color: iconColor),
      suffixIcon: _searchTerm.isEmpty
          ? null
          : IconButton(
              onPressed: _clearSearch,
              icon: Icon(Icons.clear, color: iconColor),
            ),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusBorderColor, width: 2),
      ),
      hintStyle: TextStyle(color: hintColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = ControlTiemposPalette.of(theme);
    final textTheme = theme.textTheme;
    final int selectedCount = _selectedVolquetes.length;
    final bool hasSelection = selectedCount > 0;

    return AppShell(
      title: 'ToolMAPE',
      backgroundColor: palette.background,
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      onGoToControlTiempos: () =>
          Navigator.pushReplacementNamed(context, routeControlTiempos),
      onGoToInformacion: () =>
          Navigator.pushReplacementNamed(context, routeInformacion),
      floatingActionButton: FloatingActionButton(
        backgroundColor: palette.accent,
        foregroundColor: palette.onAccent,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: _BottomNavToggleButton(
                label: 'Carga',
                asset: _iconExcavatorCarga,
                isSelected: _selectedBottomIndex == 0,
                onTap: () {
                  if (_selectedBottomIndex != 0) {
                    setState(() {
                      _selectedBottomIndex = 0;
                    });
                  }
                },
                palette: palette,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BottomNavToggleButton(
                label: 'Descarga',
                asset: _iconExcavatorDescarga,
                isSelected: _selectedBottomIndex == 1,
                onTap: () {
                  if (_selectedBottomIndex != 1) {
                    setState(() {
                      _selectedBottomIndex = 1;
                    });
                  }
                },
                palette: palette,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: palette.background,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: palette.tabContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(8),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: palette.onAccent,
                  unselectedLabelColor: palette.mutedText,
                  tabs: const [
                    Tab(
                      child: _TabIconLabel(
                        asset: _iconLoaderTab,
                        label: 'Cargador',
                      ),
                    ),
                    Tab(
                      child: _TabIconLabel(
                        asset: _iconExcavatorTab,
                        label: 'Excavadora',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: palette.primaryText),
                      decoration: _searchDecoration(
                        fillColor: palette.searchFill,
                        borderColor: palette.outline,
                        focusBorderColor: palette.accent,
                        iconColor: palette.mutedText,
                        hintColor: palette.hint,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _toggleSelectionMode,
                    icon: Icon(
                      _isSelectionMode
                          ? Icons.close
                          : Icons.checklist_rtl_rounded,
                    ),
                    label: Text(
                        _isSelectionMode ? 'Cancelar' : 'Seleccionar'),
                  ),
                  if (_isSelectionMode) ...[
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: hasSelection ? _markSelectedAsComplete : null,
                      icon: const Icon(Icons.done_all),
                      label: const Text('Completar'),
                    ),
                  ],
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _refreshList,
                    icon: Icon(Icons.refresh, color: palette.icon),
                    tooltip: 'Actualizar',
                  ),
                ],
              ),
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          hasSelection
                              ? '$selectedCount registro${selectedCount == 1 ? '' : 's'} seleccionados.'
                              : 'Selecciona registros para aplicar acciones masivas.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: palette.mutedText,
                            fontWeight: hasSelection
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (hasSelection)
                        TextButton(
                          onPressed: _clearSelection,
                          child: const Text('Limpiar'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredVolquetes.isEmpty
                    ? _EmptyVolquetesView(palette: palette)
                    : ListView.separated(
                        itemCount: _filteredVolquetes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final volquete = _filteredVolquetes[index];
                          return _VolqueteCard(
                            volquete: volquete,
                            dateFormat: _dateFormat,
                            onTap: () => _handleVolqueteTap(volquete),
                            onLongPress: () =>
                                _handleVolqueteLongPress(volquete),
                            onEdit: () => _openForm(
                              initial: volquete,
                              mode: VolqueteFormMode.edit,
                            ),
                            onViewVolquete: () => _openVolqueteInfo(volquete),
                            onStartManiobra: () => _showSnack(
                              'Inicio de maniobra registrado para ${volquete.codigo}.',
                            ),
                            onStartCarga: () => _showSnack(
                              'Inicio de carga marcado para ${volquete.codigo}.',
                            ),
                            onEndCarga: () =>
                                _registerFinCargaFromList(volquete),
                            onFinishOperacion: () => _showSnack(
                              'Operación finalizada para ${volquete.codigo}.',
                            ),
                            isSelectionMode: _isSelectionMode,
                            isSelected:
                                _selectedVolquetes.contains(volquete.id),
                            onToggleSelection: () =>
                                _toggleVolqueteSelection(volquete),
                            palette: palette,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _BottomNavToggleButton extends StatelessWidget {
  const _BottomNavToggleButton({
    required this.label,
    required this.asset,
    required this.isSelected,
    required this.onTap,
    required this.palette,
  });

  final String label;
  final String asset;
  final bool isSelected;
  final VoidCallback onTap;
  final ControlTiemposPalette palette;

  @override
  Widget build(BuildContext context) {
    final Color background =
        isSelected ? palette.accent : palette.surface;
    final Color foreground =
        isSelected ? palette.onAccent : palette.mutedText;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabIconLabel extends StatelessWidget {
  const _TabIconLabel({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color color = DefaultTextStyle.of(context).style.color ??
        Theme.of(context).colorScheme.onSurface;
    final TextStyle textStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(color: color) ??
            TextStyle(color: color);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          asset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _EmptyVolquetesView extends StatelessWidget {
  const _EmptyVolquetesView({required this.palette});

  final ControlTiemposPalette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: palette.emptyIcon),
          const SizedBox(height: 12),
          Text(
            'No se encontraron registros',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.mutedText,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajusta los filtros o registra un nuevo volquete.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.subtleText,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VolqueteCard extends StatelessWidget {
  const _VolqueteCard({
    required this.volquete,
    required this.dateFormat,
    required this.onTap,
    required this.onLongPress,
    required this.onEdit,
    required this.onViewVolquete,
    required this.onStartManiobra,
    required this.onStartCarga,
    required this.onEndCarga,
    required this.onFinishOperacion,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onToggleSelection,
    required this.palette,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onViewVolquete;
  final VoidCallback onStartManiobra;
  final VoidCallback onStartCarga;
  final VoidCallback onEndCarga;
  final VoidCallback onFinishOperacion;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final ControlTiemposPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final Color cardColor = isSelected
        ? Color.alphaBlend(palette.selectionFill, palette.surface)
        : palette.surface;
    final BorderSide borderSide = BorderSide(
      color: isSelected ? palette.selectionBorder : palette.outline,
      width: isSelected ? 1.5 : 1,
    );
    final EdgeInsets padding =
        isSelectionMode ? const EdgeInsets.fromLTRB(56, 16, 16, 16) : const EdgeInsets.all(16);

    final TextStyle titleStyle = textTheme.titleMedium?.copyWith(
          color: palette.primaryText,
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(color: palette.primaryText, fontWeight: FontWeight.w700);
    final TextStyle detailStyle =
        textTheme.bodySmall?.copyWith(color: palette.mutedText) ??
            TextStyle(color: palette.mutedText);
    final TextStyle subtleStyle =
        textTheme.bodySmall?.copyWith(color: palette.subtleText) ??
            TextStyle(color: palette.subtleText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSelectionMode ? onToggleSelection : onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              padding: padding,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.fromBorderSide(borderSide),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onViewVolquete,
                          child: Text(
                            volquete.codigo,
                            style: titleStyle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StatusText(estado: volquete.estado, palette: palette),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateFormat.format(volquete.fecha),
                              style: subtleStyle,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${volquete.maquinaria} • Chute ${volquete.chute}',
                              style: detailStyle,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              volquete.procedencias.join(' / '),
                              style: detailStyle,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionIconButton(
                            tooltip: 'Inicio de maniobra',
                            onPressed: onStartManiobra,
                            icon: SvgPicture.asset(
                              _iconArrowRight,
                              width: 22,
                              height: 22,
                              colorFilter:
                                  ColorFilter.mode(palette.icon, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActionIconButton(
                            tooltip: 'Inicio de carga',
                            onPressed: onStartCarga,
                            icon: SvgPicture.asset(
                              _iconTruckEmpty,
                              width: 22,
                              height: 22,
                              colorFilter:
                                  ColorFilter.mode(palette.icon, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActionIconButton(
                            tooltip: 'Fin de carga',
                            onPressed: onEndCarga,
                            icon: SvgPicture.asset(
                              _iconTruckLoaded,
                              width: 22,
                              height: 22,
                              colorFilter:
                                  ColorFilter.mode(palette.icon, BlendMode.srcIn),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActionIconButton(
                            tooltip: 'Finalizar operación',
                            onPressed: onFinishOperacion,
                            icon: Icon(
                              Icons.timer_outlined,
                              color: palette.icon,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ActionIconButton(
                            tooltip: 'Editar',
                            onPressed: onEdit,
                            icon: SvgPicture.asset(
                              _iconEditPen,
                              width: 22,
                              height: 22,
                              colorFilter:
                                  ColorFilter.mode(palette.icon, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelectionMode)
              Positioned(
                top: 16,
                left: 16,
                child: _SelectionIndicator(
                  selected: isSelected,
                  palette: palette,
                  onPressed: onToggleSelection,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.estado, required this.palette});

  final VolqueteEstado estado;
  final ControlTiemposPalette palette;

  @override
  Widget build(BuildContext context) {
    final bool completo = estado == VolqueteEstado.completo;
    final Color color = completo ? palette.success : palette.accent;

    return Text(
      estado.label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ) ??
          TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.selected,
    required this.palette,
    required this.onPressed,
  });

  final bool selected;
  final ControlTiemposPalette palette;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: selected
                ? palette.accent
                : palette.surface.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? palette.selectionBorder : palette.outline,
              width: selected ? 1.3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selected
                ? Icon(
                    Icons.check,
                    key: const ValueKey(true),
                    color: palette.onAccent,
                    size: 18,
                  )
                : Icon(
                    Icons.circle_outlined,
                    key: const ValueKey(false),
                    color: palette.mutedText,
                    size: 18,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        visualDensity: VisualDensity.compact,
        splashRadius: 22,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

final List<Volquete> _initialVolquetes = [
  Volquete(
    id: 'v10',
    codigo: '(V10) Volq. MG B9G-917',
    placa: 'MG B9G-917',
    operador: '(E01) Excav. C 340-01',
    destino: 'Beatriz 1',
    fecha: DateTime(2025, 7, 22, 8, 45, 39),
    estado: VolqueteEstado.incompleto,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    maquinaria: '(E01) Excav. C 340-01',
    procedencias: const ['Beatriz 1'],
    chute: 3,
    llegadaFrente: DateTime(2025, 7, 22, 8, 40),
    inicioManiobra: DateTime(2025, 7, 22, 8, 42),
    inicioCarga: DateTime(2025, 7, 22, 8, 47),
    finCarga: null,
    documento: 'OT-000912.pdf',
    notas: 'Operación en espera de confirmación de balanza.',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a frente',
        descripcion: 'Arribo a zona Beatriz 1 con guía interna 00124.',
        fecha: DateTime(2025, 7, 22, 8, 40),
        icon: VolqueteEventoIcon.arrow,
      ),
      VolqueteEvento(
        titulo: 'Preparación para carga',
        descripcion: 'Asignado al chute 3.',
        fecha: DateTime(2025, 7, 22, 8, 42),
        icon: VolqueteEventoIcon.truckEmpty,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd100',
        volquete: '(V10) Volq. MG B9G-917',
        procedencia: 'Beatriz 1',
        chute: 3,
        fechaInicio: DateTime(2025, 7, 21, 23, 20),
        fechaFin: DateTime(2025, 7, 21, 23, 54),
      ),
      VolqueteDescarga(
        id: 'd101',
        volquete: '(V07) Volq. MG B9G-917',
        procedencia: 'Beatriz 2',
        chute: 2,
        fechaInicio: DateTime(2025, 7, 20, 21, 15),
        fechaFin: DateTime(2025, 7, 20, 21, 44),
      ),
    ],
  ),
  Volquete(
    id: 'v08',
    codigo: '(V08) Volq. GQ VON-840',
    placa: 'GQ VON-840',
    operador: '(E03) Carg. AD L150F',
    destino: 'Panchita 2',
    fecha: DateTime(2025, 7, 16, 9, 8, 22),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    maquinaria: '(E03) Carg. AD L150F',
    procedencias: const ['Panchita 2'],
    chute: 4,
    llegadaFrente: DateTime(2025, 7, 16, 8, 55),
    inicioManiobra: DateTime(2025, 7, 16, 8, 57),
    inicioCarga: DateTime(2025, 7, 16, 9, 1),
    finCarga: DateTime(2025, 7, 16, 9, 8),
    documento: 'OT-000898.pdf',
    notas: 'Carga confirmada y sellada.',
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Se posiciona en el chute 4.',
        fecha: DateTime(2025, 7, 16, 8, 57),
        icon: VolqueteEventoIcon.arrow,
      ),
      VolqueteEvento(
        titulo: 'Fin de carga',
        descripcion: 'Carga completada y verificada.',
        fecha: DateTime(2025, 7, 16, 9, 8),
        icon: VolqueteEventoIcon.truckLoaded,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd102',
        volquete: '(V08) Volq. GQ VON-840',
        procedencia: 'Panchita 2',
        chute: 4,
        fechaInicio: DateTime(2025, 7, 15, 18, 10),
        fechaFin: DateTime(2025, 7, 15, 18, 40),
      ),
      VolqueteDescarga(
        id: 'd103',
        volquete: '(V05) Volq. GQ VON-840',
        procedencia: 'Beatriz 3',
        chute: 5,
        fechaInicio: DateTime(2025, 7, 14, 20, 5),
        fechaFin: DateTime(2025, 7, 14, 20, 45),
      ),
    ],
  ),
  Volquete(
    id: 'v04',
    codigo: '(V04) Volq. FR D7V-760',
    placa: 'FR D7V-760',
    operador: '(E02) Excav. ZX 350',
    destino: 'Beatriz 2',
    fecha: DateTime(2025, 7, 16, 9, 2, 12),
    estado: VolqueteEstado.incompleto,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.excavadora,
    maquinaria: '(E02) Excav. ZX 350',
    procedencias: const ['Beatriz 2', 'Relavado'],
    chute: 2,
    llegadaFrente: DateTime(2025, 7, 16, 8, 48),
    inicioManiobra: DateTime(2025, 7, 16, 8, 50),
    inicioCarga: DateTime(2025, 7, 16, 8, 56),
    finCarga: null,
    documento: 'OT-000876.pdf',
    notas: 'Pendiente consolidar tonelaje final.',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a zona',
        descripcion: 'Verificación de neumáticos completada.',
        fecha: DateTime(2025, 7, 16, 8, 48),
        icon: VolqueteEventoIcon.arrow,
      ),
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Excavadora ZX 350 inicia turno.',
        fecha: DateTime(2025, 7, 16, 8, 56),
        icon: VolqueteEventoIcon.truckEmpty,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd104',
        volquete: '(V04) Volq. FR D7V-760',
        procedencia: 'Beatriz 2',
        chute: 2,
        fechaInicio: DateTime(2025, 7, 12, 7, 30),
        fechaFin: DateTime(2025, 7, 12, 7, 58),
      ),
      VolqueteDescarga(
        id: 'd105',
        volquete: '(V04) Volq. FR D7V-760',
        procedencia: 'Relavado',
        chute: 1,
        fechaInicio: DateTime(2025, 7, 11, 22, 15),
        fechaFin: DateTime(2025, 7, 11, 22, 44),
      ),
    ],
  ),
  Volquete(
    id: 'v03',
    codigo: '(V03) Volq. SR V3R-770',
    placa: 'SR V3R-770',
    operador: '(E03) Carg. AD L150F',
    destino: 'Beatriz 3',
    fecha: DateTime(2025, 7, 16, 8, 58, 2),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.cargador,
    maquinaria: '(E03) Carg. AD L150F',
    procedencias: const ['Beatriz 3'],
    chute: 5,
    llegadaFrente: DateTime(2025, 7, 16, 8, 30),
    inicioManiobra: DateTime(2025, 7, 16, 8, 32),
    inicioCarga: DateTime(2025, 7, 16, 8, 34),
    finCarga: DateTime(2025, 7, 16, 8, 58),
    documento: 'OT-000854.pdf',
    notas: 'Descarga cerrada y aprobada.',
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio descarga',
        descripcion: 'Ingreso a patio de maniobras.',
        fecha: DateTime(2025, 7, 16, 8, 40),
        icon: VolqueteEventoIcon.truckLoaded,
      ),
      VolqueteEvento(
        titulo: 'Finalización',
        descripcion: 'Peso registrado 18.7 tn.',
        fecha: DateTime(2025, 7, 16, 8, 58),
        icon: VolqueteEventoIcon.clock,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd106',
        volquete: '(V03) Volq. SR V3R-770',
        procedencia: 'Beatriz 3',
        chute: 5,
        fechaInicio: DateTime(2025, 7, 13, 12, 5),
        fechaFin: DateTime(2025, 7, 13, 12, 32),
      ),
    ],
  ),
  Volquete(
    id: 'v02',
    codigo: '(V02) Volq. NG F1X-794',
    placa: 'NG F1X-794',
    operador: '(E01) Excav. C 340-01',
    destino: 'Panchita 1',
    fecha: DateTime(2025, 7, 16, 8, 55, 10),
    estado: VolqueteEstado.incompleto,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    maquinaria: '(E01) Excav. C 340-01',
    procedencias: const ['Panchita 1'],
    chute: 1,
    llegadaFrente: DateTime(2025, 7, 16, 8, 15),
    inicioManiobra: DateTime(2025, 7, 16, 8, 18),
    inicioCarga: DateTime(2025, 7, 16, 8, 24),
    finCarga: null,
    documento: 'OT-000833.pdf',
    notas: 'Esperando confirmación de seguridad.',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a zona',
        descripcion: 'Tránsito con acompañamiento.',
        fecha: DateTime(2025, 7, 16, 8, 15),
        icon: VolqueteEventoIcon.arrow,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd107',
        volquete: '(V02) Volq. NG F1X-794',
        procedencia: 'Panchita 1',
        chute: 1,
        fechaInicio: DateTime(2025, 7, 14, 14, 40),
        fechaFin: DateTime(2025, 7, 14, 15, 5),
      ),
    ],
  ),
  Volquete(
    id: 'v01',
    codigo: '(V01) Volq. SR V3R-770',
    placa: 'SR V3R-770',
    operador: '(E02) Excav. ZX 350',
    destino: 'Relavado',
    fecha: DateTime(2025, 7, 16, 8, 54, 44),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.excavadora,
    maquinaria: '(E02) Excav. ZX 350',
    procedencias: const ['Relavado'],
    chute: 4,
    llegadaFrente: DateTime(2025, 7, 16, 8, 12),
    inicioManiobra: DateTime(2025, 7, 16, 8, 16),
    inicioCarga: DateTime(2025, 7, 16, 8, 19),
    finCarga: DateTime(2025, 7, 16, 8, 54),
    documento: 'OT-000820.pdf',
    notas: 'Operación completada sin incidencias.',
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Ingreso al chute 4.',
        fecha: DateTime(2025, 7, 16, 8, 16),
        icon: VolqueteEventoIcon.arrow,
      ),
      VolqueteEvento(
        titulo: 'Carga finalizada',
        descripcion: 'Carga conforme según control de tonelaje.',
        fecha: DateTime(2025, 7, 16, 8, 54),
        icon: VolqueteEventoIcon.truckLoaded,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd108',
        volquete: '(V01) Volq. SR V3R-770',
        procedencia: 'Relavado',
        chute: 4,
        fechaInicio: DateTime(2025, 7, 10, 6, 0),
        fechaFin: DateTime(2025, 7, 10, 6, 34),
      ),
    ],
  ),
  Volquete(
    id: 'v11',
    codigo: '(V11) Volq. SR V3R-770',
    placa: 'SR V3R-770',
    operador: '(E03) Carg. AD L150F',
    destino: 'Beatriz 1',
    fecha: DateTime(2025, 7, 8, 8, 43, 12),
    estado: VolqueteEstado.incompleto,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    maquinaria: '(E03) Carg. AD L150F',
    procedencias: const ['Beatriz 1', 'Beatriz 3'],
    chute: 2,
    llegadaFrente: DateTime(2025, 7, 8, 8, 16),
    inicioManiobra: DateTime(2025, 7, 8, 8, 20),
    inicioCarga: DateTime(2025, 7, 8, 8, 32),
    finCarga: null,
    documento: 'OT-000799.pdf',
    notas: 'Coordinar apoyo de mantenimiento.',
    eventos: [
      VolqueteEvento(
        titulo: 'Registro creado',
        descripcion: 'Ingreso manual desde panel de control.',
        fecha: DateTime(2025, 7, 8, 8, 16),
        icon: VolqueteEventoIcon.pencil,
      ),
    ],
    descargas: [
      VolqueteDescarga(
        id: 'd109',
        volquete: '(V11) Volq. SR V3R-770',
        procedencia: 'Beatriz 1',
        chute: 2,
        fechaInicio: DateTime(2025, 7, 6, 9, 20),
        fechaFin: DateTime(2025, 7, 6, 9, 50),
      ),
      VolqueteDescarga(
        id: 'd110',
        volquete: '(V11) Volq. SR V3R-770',
        procedencia: 'Beatriz 3',
        chute: 5,
        fechaInicio: DateTime(2025, 7, 5, 17, 5),
        fechaFin: DateTime(2025, 7, 5, 17, 32),
      ),
    ],
  ),
];
