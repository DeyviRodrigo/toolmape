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

const String _iconArrowRight = 'assets/icons/arrow_right.svg';
const String _iconTruckEmpty = 'assets/icons/truck_small.svg';
const String _iconTruckLoaded = 'assets/icons/truck_large.svg';
const String _iconEditPen = 'assets/icons/edit_pen.svg';

const _iconLoaderTab = 'assets/icons/loader_tab.svg';
const _iconExcavatorTab = 'assets/icons/excavator_tab.svg';
const _iconExcavatorCarga = 'assets/icons/excavator_carga.svg';
const _iconExcavatorDescarga = 'assets/icons/excavator_descarga.svg';

const Color _accentColor = Color(0xFFFF9F1C);
const Color _backgroundColor = Color(0xFF121212);
const Color _surfaceColor = Color(0xFF1E1E1E);
const Color _chipColor = Color(0xFF1C1C1C);

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
      });
    }

    if (result.createdVolquete != null) {
      setState(() {
        _volquetes = [result.createdVolquete!, ..._volquetes];
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
    });

    _showSnack('Fin de carga registrado para ${volquete.codigo}.');
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

  InputDecoration _searchDecoration() {
    return InputDecoration(
      hintText: 'Buscar volquete…',
      prefixIcon: const Icon(Icons.search, color: Colors.white70),
      suffixIcon: _searchTerm.isEmpty
          ? null
          : IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear, color: Colors.white70),
            ),
      filled: true,
      fillColor: _surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentColor, width: 2),
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    );
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
      iconTheme: baseTheme.iconTheme.copyWith(color: Colors.white),
    );

    return Theme(
      data: themed,
      child: AppShell(
        title: 'ToolMAPE',
        backgroundColor: _backgroundColor,
        onGoToCalculadora: () =>
            Navigator.pushReplacementNamed(context, routeCalculadora),
        onGoToCalendario: () =>
            Navigator.pushReplacementNamed(context, routeCalendario),
        onGoToControlTiempos: () =>
            Navigator.pushReplacementNamed(context, routeControlTiempos),
        onGoToInformacion: () =>
            Navigator.pushReplacementNamed(context, routeInformacion),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _accentColor,
          foregroundColor: Colors.black,
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
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            color: _backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white70,
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
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        style: const TextStyle(color: Colors.white),
                        decoration: _searchDecoration(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showSnack(
                        'Modo selección disponible próximamente.',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      icon: const Icon(Icons.checklist_rtl_rounded, size: 20),
                      label: const Text('Seleccionar'),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _refreshList,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _filteredVolquetes.isEmpty
                      ? const _EmptyVolquetesView()
                      : ListView.separated(
                          itemCount: _filteredVolquetes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final volquete = _filteredVolquetes[index];
                            return _VolqueteCard(
                              volquete: volquete,
                              dateFormat: _dateFormat,
                              onTap: () => _openDetail(volquete),
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
                            );
                          },
                        ),
                ),
              ],
            ),
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
  });

  final String label;
  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = isSelected ? _accentColor : _surfaceColor;
    final Color foreground = isSelected ? Colors.black : Colors.white70;

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
    final TextStyle textStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: Colors.white70) ??
        const TextStyle(color: Colors.white70);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          asset,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(label, style: textStyle),
      ],
    );
  }
}

class _EmptyVolquetesView extends StatelessWidget {
  const _EmptyVolquetesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'No se encontraron registros',
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ajusta los filtros o registra un nuevo volquete.',
            style: TextStyle(color: Colors.white54),
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
    required this.onEdit,
    required this.onViewVolquete,
    required this.onStartManiobra,
    required this.onStartCarga,
    required this.onEndCarga,
    required this.onFinishOperacion,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewVolquete;
  final VoidCallback onStartManiobra;
  final VoidCallback onStartCarga;
  final VoidCallback onEndCarga;
  final VoidCallback onFinishOperacion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusText(estado: volquete.estado),
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
                          style: const TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${volquete.maquinaria} • Chute ${volquete.chute}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          volquete.procedencias.join(' / '),
                          style: const TextStyle(color: Colors.white54),
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
                              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ActionIconButton(
                        tooltip: 'Finalizar operación',
                        onPressed: onFinishOperacion,
                        icon: const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
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
                              const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final bool completo = estado == VolqueteEstado.completo;
    final Color color = completo ? const Color(0xFF4CAF50) : _accentColor;

    return Text(
      estado.label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
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
