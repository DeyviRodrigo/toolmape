import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';

/// Página: ControlTiemposPage - espacio para gestionar actividades y tiempos.
class ControlTiemposPage extends StatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  State<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

enum VolqueteStage {
  inicioManiobra,
  finalCarga,
  inicioDescarga,
  finalDescarga,
  finalChute,
  finalExcavadora,
  editar,
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
        builder: (_) => VolqueteFormPage(initial: initial),
      ),
    );

    if (result == null) return;

    setState(() {
      final existingIndex = _volquetes.indexWhere((v) => v.id == result.id);
      if (existingIndex >= 0) {
        _volquetes[existingIndex] = result;
      } else {
        _volquetes = [..._volquetes, result];
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

  void _handleStageAction(Volquete volquete, VolqueteStage stage) {
    switch (stage) {
      case VolqueteStage.inicioManiobra:
        _showSnack('Inicio de maniobra de ${volquete.codigo}');
        break;
      case VolqueteStage.finalCarga:
        _showSnack('Final de carga registrado para ${volquete.codigo}');
        break;
      case VolqueteStage.inicioDescarga:
        _showSnack('Inicio de descarga de ${volquete.codigo}');
        break;
      case VolqueteStage.finalDescarga:
        _showSnack('Final de descarga registrado para ${volquete.codigo}');
        break;
      case VolqueteStage.finalChute:
        _showSnack('Final de chute registrado para ${volquete.codigo}');
        break;
      case VolqueteStage.finalExcavadora:
        _showSnack('Final registrado para ${volquete.codigo}');
        break;
      case VolqueteStage.editar:
        _openForm(initial: volquete);
        break;
    }
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
        child: SvgPicture.asset(
          'assets/icons/icon_fab_add.svg',
          width: 28,
          height: 28,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedBottomIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: const _NavigationSvgIcon(
              asset: 'assets/icons/icon_nav_carga.svg',
            ),
            selectedIcon: const _NavigationSvgIcon(
              asset: 'assets/icons/icon_nav_carga.svg',
              selected: true,
            ),
            label: 'Carga',
          ),
          NavigationDestination(
            icon: const _NavigationSvgIcon(
              asset: 'assets/icons/icon_nav_descarga.svg',
            ),
            selectedIcon: const _NavigationSvgIcon(
              asset: 'assets/icons/icon_nav_descarga.svg',
              selected: true,
            ),
            label: 'Descarga',
          ),
        ],
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
                  Tab(text: 'Cargador'),
                  Tab(text: 'Excavadora'),
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
                          return _VolqueteCard(
                            volquete: volquete,
                            dateFormat: _dateFormat,
                            onTap: () => _openDetail(volquete),
                            onStageSelected: (stage) =>
                                _handleStageAction(volquete, stage),
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
    required this.onStageSelected,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final ValueChanged<VolqueteStage> onStageSelected;

  List<_CardStageAction> get _actions {
    if (volquete.equipo == VolqueteEquipo.excavadora) {
      return const [
        _CardStageAction(
          stage: VolqueteStage.finalExcavadora,
          asset: 'assets/icons/icon_stage_final_excavadora.svg',
          label: 'Final',
        ),
        _CardStageAction(
          stage: VolqueteStage.editar,
          asset: 'assets/icons/icon_stage_editar.svg',
          label: 'Editar',
        ),
      ];
    }

    if (volquete.tipo == VolqueteTipo.carga) {
      return const [
        _CardStageAction(
          stage: VolqueteStage.inicioManiobra,
          asset: 'assets/icons/icon_stage_inicio_maniobra.svg',
          label: 'Inicio maniobra',
        ),
        _CardStageAction(
          stage: VolqueteStage.finalCarga,
          asset: 'assets/icons/icon_stage_final_carga.svg',
          label: 'Final carga',
        ),
        _CardStageAction(
          stage: VolqueteStage.editar,
          asset: 'assets/icons/icon_stage_editar.svg',
          label: 'Editar',
        ),
      ];
    }

    return const [
      _CardStageAction(
        stage: VolqueteStage.inicioDescarga,
        asset: 'assets/icons/icon_stage_inicio_descarga.svg',
        label: 'Inicio descarga',
      ),
      _CardStageAction(
        stage: VolqueteStage.finalDescarga,
        asset: 'assets/icons/icon_stage_final_descarga.svg',
        label: 'Final descarga',
      ),
      _CardStageAction(
        stage: VolqueteStage.finalChute,
        asset: 'assets/icons/icon_stage_final_chute.svg',
        label: 'Final chute',
      ),
      _CardStageAction(
        stage: VolqueteStage.editar,
        asset: 'assets/icons/icon_stage_editar.svg',
        label: 'Editar',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            volquete.codigo,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _EstadoChip(estado: volquete.estado),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${volquete.placa} • ${volquete.operador}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(volquete.fecha),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destino: ${volquete.destino}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _actions
                    .map(
                      (action) => _StageIconButton(
                        action: action,
                        onPressed: () => onStageSelected(action.stage),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardStageAction {
  const _CardStageAction({
    required this.stage,
    required this.asset,
    required this.label,
  });

  final VolqueteStage stage;
  final String asset;
  final String label;
}

class _StageIconButton extends StatelessWidget {
  const _StageIconButton({
    required this.action,
    required this.onPressed,
  });

  final _CardStageAction action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: action.label,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: SvgPicture.asset(
        action.asset,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurfaceVariant,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class _NavigationSvgIcon extends StatelessWidget {
  const _NavigationSvgIcon({
    required this.asset,
    this.selected = false,
  });

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final VolqueteEstado estado;

  Color _backgroundColor(BuildContext context) {
    switch (estado) {
      case VolqueteEstado.completo:
        return Colors.green.shade100;
      case VolqueteEstado.enProceso:
        return Colors.orange.shade100;
      case VolqueteEstado.pausado:
        return Colors.blueGrey.shade100;
    }
  }

  Color _textColor() {
    switch (estado) {
      case VolqueteEstado.completo:
        return Colors.green.shade800;
      case VolqueteEstado.enProceso:
        return Colors.orange.shade800;
      case VolqueteEstado.pausado:
        return Colors.blueGrey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        estado.label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(fontWeight: FontWeight.w600, color: _textColor()),
      ),
    );
  }
}

final List<Volquete> _initialVolquetes = [
  Volquete(
    id: 'v09',
    codigo: '(V09) Volq. JAA X3U-843',
    placa: 'JAA X3U-843',
    operador: 'Carlos Velarde',
    destino: 'Frente 12 - Zona A',
    fecha: DateTime(2025, 3, 27, 15, 30),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V09.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Carga completada',
        descripcion: 'Carga registrada por operador en turno matutino.',
        fecha: DateTime(2025, 3, 27, 15, 20),
      ),
      VolqueteEvento(
        titulo: 'Salida hacia depósito',
        descripcion: 'Salida autorizada con guía interna 000912.',
        fecha: DateTime(2025, 3, 27, 15, 30),
      ),
    ],
  ),
  Volquete(
    id: 'v05',
    codigo: '(V05) Volq. GQ VQN-840',
    placa: 'GQ VQN-840',
    operador: 'Ana Espino',
    destino: 'Depósito central',
    fecha: DateTime(2025, 3, 27, 14, 45),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V05.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a carguío',
        descripcion: 'Arribo al frente con orden de servicio 000234.',
        fecha: DateTime(2025, 3, 27, 14, 10),
      ),
      VolqueteEvento(
        titulo: 'Pesaje preliminar',
        descripcion: 'Peso registrado 18.2 tn.',
        fecha: DateTime(2025, 3, 27, 14, 40),
      ),
    ],
  ),
  Volquete(
    id: 'v02',
    codigo: '(V02) Volq. RD F7V-760',
    placa: 'RD F7V-760',
    operador: 'Luis Ramos',
    destino: 'Botadero norte',
    fecha: DateTime(2025, 3, 27, 13, 10),
    estado: VolqueteEstado.pausado,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V02.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Inicio autorizado por supervisor.',
        fecha: DateTime(2025, 3, 27, 12, 50),
      ),
      VolqueteEvento(
        titulo: 'Pausa temporal',
        descripcion: 'En espera por mantenimiento del frente.',
        fecha: DateTime(2025, 3, 27, 13, 5),
      ),
    ],
  ),
  Volquete(
    id: 'v11',
    codigo: '(V11) Volq. JAA X3U-843',
    placa: 'JAA X3U-843',
    operador: 'Carlos Velarde',
    destino: 'Planta de chancado',
    fecha: DateTime(2025, 3, 27, 16, 10),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V11.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ruta asignada',
        descripcion: 'Excavadora CX-02 designada para descarga.',
        fecha: DateTime(2025, 3, 27, 15, 50),
      ),
      VolqueteEvento(
        titulo: 'Descarga iniciada',
        descripcion: 'Inicia maniobra en planta.',
        fecha: DateTime(2025, 3, 27, 16, 5),
      ),
    ],
  ),
  Volquete(
    id: 'v14',
    codigo: '(V14) Volq. GQ VQN-840',
    placa: 'GQ VQN-840',
    operador: 'Ana Espino',
    destino: 'Depósito temporal B',
    fecha: DateTime(2025, 3, 27, 11, 30),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V14.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a descarga',
        descripcion: 'Control de acceso completado.',
        fecha: DateTime(2025, 3, 27, 11, 5),
      ),
      VolqueteEvento(
        titulo: 'Descarga completada',
        descripcion: 'Material dispuesto en depósito temporal.',
        fecha: DateTime(2025, 3, 27, 11, 25),
      ),
    ],
  ),
  Volquete(
    id: 'v20',
    codigo: '(V20) Volq. RD F7V-760',
    placa: 'RD F7V-760',
    operador: 'Luis Ramos',
    destino: 'Botadero norte',
    fecha: DateTime(2025, 3, 27, 10, 45),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V20.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Salida de planta',
        descripcion: 'Traslado con guía de transporte 001122.',
        fecha: DateTime(2025, 3, 27, 10, 20),
      ),
      VolqueteEvento(
        titulo: 'En ruta',
        descripcion: 'Esperando autorización para descarga.',
        fecha: DateTime(2025, 3, 27, 10, 40),
      ),
    ],
  ),
];
