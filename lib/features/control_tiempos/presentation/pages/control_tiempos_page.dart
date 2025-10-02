import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';

const _iconArrowRight = 'assets/icons/arrow_right.svg';
const _iconEditPen = 'assets/icons/edit_pen.svg';

// Nuevos íconos (rama codex)
const _iconLoaderTab = 'assets/icons/loader_tab.svg';
const _iconExcavatorTab = 'assets/icons/excavator_tab.svg';
const _iconExcavatorCarga = 'assets/icons/excavator_carga.svg';
const _iconExcavatorDescarga = 'assets/icons/excavator_descarga.svg';
const _iconTruckEmpty = 'assets/icons/truck_small.svg';
const _iconTruckFull = 'assets/icons/truck_large.svg';

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
    _volquetes = _initialVolquetes;
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchTerm = value.trim().toLowerCase();
      });
    });
  }

  Future<void> _openForm({Volquete? initial}) async {
    final result = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(
          initial: initial,
          initialEquipo: initial?.equipo ?? _selectedEquipo,
          initialTipo: initial?.tipo ?? _selectedTipo,
        ),
      ),
    );

    if (result == null) return;

    final normalized = result.copyWith(
      estado: result.finCarga != null
          ? VolqueteEstado.completo
          : VolqueteEstado.enProceso,
    );

    setState(() {
      final existingIndex = _volquetes.indexWhere((v) => v.id == normalized.id);
      if (existingIndex >= 0) {
        _volquetes[existingIndex] = normalized;
      } else {
        _volquetes = [..._volquetes, normalized];
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(initial == null
            ? 'Volquete registrado correctamente'
            : 'Volquete actualizado correctamente'),
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
        const SnackBar(content: Text('Volquete eliminado')),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volquete actualizado')),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  List<Volquete> get _filteredVolquetes {
    final filtered = _volquetes.where((volquete) {
      if (volquete.equipo != _selectedEquipo) return false;
      if (volquete.tipo != _selectedTipo) return false;
      if (_searchTerm.isEmpty) return true;

      final term = _searchTerm;
      return volquete.codigo.toLowerCase().contains(term) ||
          volquete.placa.toLowerCase().contains(term) ||
          volquete.operador.toLowerCase().contains(term);
    }).toList();

    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Control de tiempos',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      onGoToControlTiempos: () =>
          Navigator.pushReplacementNamed(context, routeControlTiempos),
      onGoToInformacion: () =>
          Navigator.pushReplacementNamed(context, routeInformacion),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                controller: _tabController,
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
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar volquete…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchTerm.isEmpty
                      ? null
                      : IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.clear),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                          final bool canStartManiobra =
                              volquete.finCarga == null && volquete.inicioManiobra == null;
                          final bool canStartCarga = volquete.finCarga == null &&
                              volquete.inicioManiobra != null &&
                              volquete.inicioCarga == null;
                          final bool canFinishCarga = volquete.finCarga == null &&
                              volquete.inicioCarga != null;

                          return _VolqueteCard(
                            volquete: volquete,
                            dateFormat: _dateFormat,
                            onTap: () => _openDetail(volquete),
                            onEdit: () => _openForm(initial: volquete),
                            onInicioManiobra: canStartManiobra
                                ? () => _registerInicioManiobra(volquete)
                                : null,
                            onInicioCarga: canStartCarga
                                ? () => _registerInicioCarga(volquete)
                                : null,
                            onFinCarga:
                                canFinishCarga ? () => _registerFinCarga(volquete) : null,
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _updateVolqueteFlow(
    String volqueteId,
    Volquete Function(Volquete current) transformer,
  ) {
    setState(() {
      _volquetes = _volquetes.map((volquete) {
        if (volquete.id != volqueteId) return volquete;
        final transformed = transformer(volquete);
        final resolvedEstado = transformed.finCarga != null
            ? VolqueteEstado.completo
            : VolqueteEstado.enProceso;
        return transformed.copyWith(estado: resolvedEstado);
      }).toList();
    });
  }

  void _registerInicioManiobra(Volquete volquete) {
    if (volquete.finCarga != null) {
      _showSnack('El volquete ya completó la carga.');
      return;
    }
    if (volquete.inicioManiobra != null) {
      _showSnack('El inicio de maniobra ya fue registrado.');
      return;
    }

    final now = DateTime.now();
    _updateVolqueteFlow(
      volquete.id,
      (current) => current.copyWith(
        inicioManiobra: now,
        eventos: [
          ...current.eventos,
          VolqueteEvento(
            titulo: 'Inicio de maniobra',
            descripcion: 'Registrado desde el panel de control.',
            fecha: now,
          ),
        ],
      ),
    );
    _showSnack('Inicio de maniobra registrado');
  }

  void _registerInicioCarga(Volquete volquete) {
    if (volquete.finCarga != null) {
      _showSnack('El volquete ya completó la carga.');
      return;
    }
    if (volquete.inicioManiobra == null) {
      _showSnack('Registra el inicio de maniobra antes de continuar.');
      return;
    }
    if (volquete.inicioCarga != null) {
      _showSnack('El inicio de carga ya fue registrado.');
      return;
    }

    final now = DateTime.now();
    _updateVolqueteFlow(
      volquete.id,
      (current) => current.copyWith(
        inicioCarga: now,
        eventos: [
          ...current.eventos,
          VolqueteEvento(
            titulo: 'Inicio de carga',
            descripcion: 'Registrado desde el panel de control.',
            fecha: now,
          ),
        ],
      ),
    );
    _showSnack('Inicio de carga registrado');
  }

  void _registerFinCarga(Volquete volquete) {
    if (volquete.finCarga != null) {
      _showSnack('El fin de carga ya fue registrado.');
      return;
    }
    if (volquete.inicioManiobra == null || volquete.inicioCarga == null) {
      _showSnack('Completa los pasos previos antes de finalizar la carga.');
      return;
    }

    final now = DateTime.now();
    _updateVolqueteFlow(
      volquete.id,
      (current) => current.copyWith(
        finCarga: now,
        fecha: now,
        eventos: [
          ...current.eventos,
          VolqueteEvento(
            titulo: 'Fin de carga',
            descripcion: 'Registro automático desde el panel.',
            fecha: now,
          ),
        ],
      ),
    );
    _showSnack('Fin de carga registrado');
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
    const Color selectedBackground = Color(0xFFF97316);
    const Color unselectedBackground = Color(0xFF1F2937);
    final Color background = isSelected ? selectedBackground : unselectedBackground;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                width: 28,
                height: 28,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
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
    final Color iconColor =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    final TextStyle textStyle = DefaultTextStyle.of(context).style;
    final Color resolvedTextColor = textStyle.color ?? iconColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: textStyle.copyWith(color: resolvedTextColor),
        ),
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
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text('No se encontraron registros'),
          const SizedBox(height: 4),
          Text(
            'Ajusta los filtros o registra un nuevo volquete.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
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
    required this.onInicioManiobra,
    required this.onInicioCarga,
    required this.onFinCarga,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onInicioManiobra;
  final VoidCallback? onInicioCarga;
  final VoidCallback? onFinCarga;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color cardBackground = Color(0xFF111827);
    final bool isCompleto = volquete.finCarga != null;
    final Color statusColor = isCompleto
        ? const Color(0xFF34D399)
        : const Color(0xFFFBBF24);
    final String statusLabel = isCompleto ? 'Completo' : 'Incompleto';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volquete.codigo,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            volquete.placa,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          statusLabel,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(volquete.fecha),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Procedencia: ${volquete.procedencia}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Text(
                      'Chute ${volquete.chute}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Llegada al frente: ${dateFormat.format(volquete.llegadaFrente)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                if (volquete.observaciones != null &&
                    volquete.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    volquete.observaciones!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _FlowActionButton(
                      asset: _iconArrowRight,
                      tooltip: 'Inicio de maniobra',
                      isCompleted: volquete.inicioManiobra != null,
                      onPressed: onInicioManiobra,
                    ),
                    const SizedBox(width: 8),
                    _FlowActionButton(
                      asset: _iconTruckEmpty,
                      tooltip: 'Inicio de carga',
                      isCompleted: volquete.inicioCarga != null,
                      onPressed: onInicioCarga,
                    ),
                    const SizedBox(width: 8),
                    _FlowActionButton(
                      asset: _iconTruckFull,
                      tooltip: 'Fin de carga',
                      isCompleted: volquete.finCarga != null,
                      onPressed: onFinCarga,
                    ),
                    const SizedBox(width: 8),
                    _FlowActionButton(
                      asset: _iconEditPen,
                      tooltip: 'Editar registro',
                      isCompleted: true,
                      onPressed: onEdit,
                      highlightColor: theme.colorScheme.secondary,
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

class _FlowActionButton extends StatelessWidget {
  const _FlowActionButton({
    required this.asset,
    required this.tooltip,
    required this.isCompleted,
    this.onPressed,
    this.highlightColor,
  });

  final String asset;
  final String tooltip;
  final bool isCompleted;
  final VoidCallback? onPressed;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color accent = highlightColor ?? theme.colorScheme.primary;
    final bool isEnabled = onPressed != null;
    final Color iconColor = isCompleted
        ? accent
        : isEnabled
            ? Colors.white70
            : Colors.white38;
    final Color backgroundColor = isCompleted
        ? accent.withOpacity(0.18)
        : Colors.white.withOpacity(isEnabled ? 0.08 : 0.04);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              asset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

final List<Volquete> _initialVolquetes = [
  Volquete(
    id: 'v12',
    codigo: '(V12) Volqu. DJ F2J-854',
    placa: 'DJ F2J-854',
    operador: 'Turno Beatriz',
    destino: 'Chute 2',
    fecha: DateTime(2025, 6, 27, 13, 3, 3),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    procedencia: 'Beatriz 1',
    chute: 2,
    llegadaFrente: DateTime(2025, 6, 27, 12, 45),
    observaciones: 'Operación sin novedades.',
    documento: 'OrdenCarga_V12.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 12, 46),
    inicioCarga: DateTime(2025, 6, 27, 12, 50),
    finCarga: DateTime(2025, 6, 27, 13, 3),
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Posicionamiento del volquete en frente Beatriz.',
        fecha: DateTime(2025, 6, 27, 12, 46),
      ),
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Cargador WA600 inicia ciclo controlado.',
        fecha: DateTime(2025, 6, 27, 12, 50),
      ),
      VolqueteEvento(
        titulo: 'Fin de carga',
        descripcion: 'Carga completada y autorizada por supervisor.',
        fecha: DateTime(2025, 6, 27, 13, 3),
      ),
    ],
  ),
  Volquete(
    id: 'v10',
    codigo: '(V10) Volqu. MG B9P-657',
    placa: 'MG B9P-657',
    operador: 'Turno Panchita',
    destino: 'Chute 4',
    fecha: DateTime(2025, 6, 27, 12, 58),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    procedencia: 'Panchita 2',
    chute: 4,
    llegadaFrente: DateTime(2025, 6, 27, 12, 30),
    observaciones: 'Esperando confirmación de báscula.',
    documento: 'OrdenCarga_V10.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 12, 32),
    inicioCarga: DateTime(2025, 6, 27, 12, 40),
    finCarga: null,
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Volquete alineado con cargador frontal.',
        fecha: DateTime(2025, 6, 27, 12, 32),
      ),
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Registro de carga parcial a las 12:40.',
        fecha: DateTime(2025, 6, 27, 12, 40),
      ),
    ],
  ),
  Volquete(
    id: 'v05',
    codigo: '(V05) Volqu. EO X2Q-733',
    placa: 'EO X2Q-733',
    operador: 'Turno Relavado',
    destino: 'Chute 1',
    fecha: DateTime(2025, 6, 27, 12, 20),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    procedencia: 'Relavado',
    chute: 1,
    llegadaFrente: DateTime(2025, 6, 27, 12, 5),
    observaciones: 'A la espera de disponibilidad del cargador.',
    documento: 'OrdenCarga_V05.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 12, 7),
    inicioCarga: null,
    finCarga: null,
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Volquete ubicado en frente principal.',
        fecha: DateTime(2025, 6, 27, 12, 7),
      ),
    ],
  ),
  Volquete(
    id: 'v03',
    codigo: '(V03) Volqu. GM B7K-757',
    placa: 'GM B7K-757',
    operador: 'Turno Beatriz',
    destino: 'Chute 3',
    fecha: DateTime(2025, 6, 27, 11, 54),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    procedencia: 'Beatriz 2',
    chute: 3,
    llegadaFrente: DateTime(2025, 6, 27, 11, 20),
    observaciones: 'Carga completada sin incidentes.',
    documento: 'OrdenCarga_V03.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 11, 22),
    inicioCarga: DateTime(2025, 6, 27, 11, 30),
    finCarga: DateTime(2025, 6, 27, 11, 50),
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Ingreso a Beatriz 2 reportado por operador.',
        fecha: DateTime(2025, 6, 27, 11, 22),
      ),
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Se inicia carga supervisada.',
        fecha: DateTime(2025, 6, 27, 11, 30),
      ),
      VolqueteEvento(
        titulo: 'Fin de carga',
        descripcion: 'Carga liberada hacia báscula central.',
        fecha: DateTime(2025, 6, 27, 11, 50),
      ),
    ],
  ),
  Volquete(
    id: 'd21',
    codigo: '(V21) Volqu. DJ F2J-854',
    placa: 'DJ F2J-854',
    operador: 'Turno Descarga',
    destino: 'Botadero norte',
    fecha: DateTime(2025, 6, 27, 15, 12),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    procedencia: 'Panchita 1',
    chute: 5,
    llegadaFrente: DateTime(2025, 6, 27, 14, 40),
    observaciones: 'Descarga finalizada y validada.',
    documento: 'OrdenDescarga_V21.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 14, 42),
    inicioCarga: DateTime(2025, 6, 27, 14, 50),
    finCarga: DateTime(2025, 6, 27, 15, 10),
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Ingreso al botadero autorizado.',
        fecha: DateTime(2025, 6, 27, 14, 42),
      ),
      VolqueteEvento(
        titulo: 'Inicio de descarga',
        descripcion: 'Excavadora RX-04 posicionada.',
        fecha: DateTime(2025, 6, 27, 14, 50),
      ),
      VolqueteEvento(
        titulo: 'Fin de descarga',
        descripcion: 'Material dispuesto correctamente.',
        fecha: DateTime(2025, 6, 27, 15, 10),
      ),
    ],
  ),
  Volquete(
    id: 'd22',
    codigo: '(V22) Volqu. EO X2Q-733',
    placa: 'EO X2Q-733',
    operador: 'Turno Descarga',
    destino: 'Botadero sur',
    fecha: DateTime(2025, 6, 27, 14, 58),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    procedencia: 'Relavado',
    chute: 4,
    llegadaFrente: DateTime(2025, 6, 27, 14, 20),
    observaciones: 'Esperando señal del supervisor para descargar.',
    documento: 'OrdenDescarga_V22.pdf',
    notas: null,
    inicioManiobra: DateTime(2025, 6, 27, 14, 25),
    inicioCarga: DateTime(2025, 6, 27, 14, 40),
    finCarga: null,
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de maniobra',
        descripcion: 'Ruta segura confirmada por logística.',
        fecha: DateTime(2025, 6, 27, 14, 25),
      ),
      VolqueteEvento(
        titulo: 'Inicio de descarga',
        descripcion: 'Esperando autorización de botadero.',
        fecha: DateTime(2025, 6, 27, 14, 40),
      ),
    ],
  ),
  Volquete(
    id: 'd23',
    codigo: '(V23) Volqu. KQ P9J-301',
    placa: 'KQ P9J-301',
    operador: 'Turno Descarga',
    destino: 'Depósito temporal C',
    fecha: DateTime(2025, 6, 27, 14, 12),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    procedencia: 'Beatriz 1',
    chute: 3,
    llegadaFrente: DateTime(2025, 6, 27, 13, 50),
    observaciones: 'Pendiente de autorización para iniciar maniobra.',
    documento: 'OrdenDescarga_V23.pdf',
    notas: null,
    inicioManiobra: null,
    inicioCarga: null,
    finCarga: null,
    eventos: [
      VolqueteEvento(
        titulo: 'Registro creado',
        descripcion: 'Volquete asignado desde panel de control.',
        fecha: DateTime(2025, 6, 27, 13, 50),
      ),
    ],
  ),
];
