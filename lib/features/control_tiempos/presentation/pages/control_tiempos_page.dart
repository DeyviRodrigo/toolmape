import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/infrastructure/datasources/volquetes_supabase_datasource.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';

const _iconArrowRight = 'assets/icons/arrow_right.svg';
const _iconEditPen = 'assets/icons/edit_pen.svg';
const _iconTruckLoaded = 'assets/icons/truck_large.svg';
const _iconTruckEmpty = 'assets/icons/truck_small.svg';

// Nuevos íconos (rama codex)
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

  List<Volquete> _volquetes = const [];
  VolquetesSupabaseDatasource? _datasource;
  bool _isLoading = false;
  bool _isOfflineMode = false;
  String? _errorMessage;
  int _selectedBottomIndex = 0;
  String _searchTerm = '';
  Timer? _debounce;

  bool get _isVolqueteTab => _tabController.index == 0;

  VolqueteEquipo? get _selectedEquipo {
    switch (_tabController.index) {
      case 1:
        return VolqueteEquipo.cargador;
      case 2:
        return VolqueteEquipo.excavadora;
      default:
        return null;
    }
  }

  VolqueteTipo get _selectedTipo =>
      _selectedBottomIndex == 0 ? VolqueteTipo.carga : VolqueteTipo.descarga;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _datasource = _maybeCreateDatasource();
    _loadVolquetes();
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

  VolquetesSupabaseDatasource? _maybeCreateDatasource() {
    try {
      final client = Supabase.instance.client;
      return VolquetesSupabaseDatasource(client);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadVolquetes() async {
    _datasource ??= _maybeCreateDatasource();

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final datasource = _datasource;

    if (datasource == null) {
      setState(() {
        _volquetes = _initialVolquetes;
        _isOfflineMode = true;
        _errorMessage = 'Configura las credenciales de Supabase para sincronizar tus volquetes.';
        _isLoading = false;
      });
      return;
    }

    try {
      final items = await datasource.fetchVolquetes();
      if (!mounted) return;
      setState(() {
        _volquetes = items;
        _isOfflineMode = false;
        _errorMessage = null;
      });
    } on VolquetesDatasourceException catch (error) {
      if (!mounted) return;
      setState(() {
        _volquetes = _initialVolquetes;
        _isOfflineMode = true;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _volquetes = _initialVolquetes;
        _isOfflineMode = true;
        _errorMessage = 'Error inesperado al conectar con Supabase.';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveVolquete(Volquete volquete, {required bool isNew}) async {
    _datasource ??= _maybeCreateDatasource();

    var resolved = volquete;
    var offline = false;
    String? syncMessage;

    try {
      final datasource = _datasource;
      if (datasource != null) {
        resolved = await datasource.upsertVolquete(volquete);
      } else {
        offline = true;
        syncMessage = 'Supabase no está configurado. Se guardó el registro localmente.';
      }
    } on VolquetesDatasourceException catch (error) {
      offline = true;
      syncMessage = error.message;
    } catch (_) {
      offline = true;
      syncMessage = 'No se pudo sincronizar con Supabase. El registro se guardó de forma local.';
    }

    if (!mounted) return;

    setState(() {
      _isOfflineMode = offline;
      _errorMessage = offline ? syncMessage : null;
      final updatedList = _volquetes
          .where((v) => v.id != volquete.id && v.id != resolved.id)
          .toList()
        ..add(resolved)
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
      _volquetes = updatedList;
    });

    final message = offline
        ? (isNew
            ? 'Volquete registrado sin conexión.'
            : 'Cambios guardados sin conexión.')
        : (isNew ? 'Volquete registrado correctamente' : 'Volquete actualizado correctamente');

    _showSnack(message);
  }

  Future<void> _deleteVolquete(String id) async {
    _datasource ??= _maybeCreateDatasource();

    var offline = false;
    String? syncMessage;

    try {
      final datasource = _datasource;
      if (datasource != null) {
        await datasource.deleteVolquete(id);
      } else {
        offline = true;
        syncMessage = 'Supabase no está configurado. Se eliminó el registro localmente.';
      }
    } on VolquetesDatasourceException catch (error) {
      offline = true;
      syncMessage = error.message;
    } catch (_) {
      offline = true;
      syncMessage = 'No se pudo eliminar el volquete en Supabase.';
    }

    if (!mounted) return;

    setState(() {
      _volquetes = _volquetes.where((v) => v.id != id).toList();
      _isOfflineMode = offline;
      _errorMessage = offline ? syncMessage : null;
    });

    _showSnack(offline ? 'Volquete eliminado sin conexión.' : 'Volquete eliminado');
  }

  Future<void> _openForm({Volquete? initial}) async {
    final result = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(
          initial: initial,
          defaultTipo: _isVolqueteTab ? _selectedTipo : null,
          defaultEquipo: _selectedEquipo,
        ),
      ),
    );

    if (result == null) return;

    await _saveVolquete(result, isNew: initial == null);
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
      await _deleteVolquete(result.deletedVolqueteId!);
      return;
    }

    if (result.updatedVolquete != null) {
      await _saveVolquete(result.updatedVolquete!, isNew: false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  List<Volquete> get _filteredVolquetes {
    final equipoFilter = _selectedEquipo;
    final tipoFilter = _isVolqueteTab ? _selectedTipo : null;

    final filtered = _volquetes.where((volquete) {
      if (equipoFilter != null && volquete.equipo != equipoFilter) return false;
      if (tipoFilter != null && volquete.tipo != tipoFilter) return false;
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
      bottomNavigationBar: _isVolqueteTab
          ? SafeArea(
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
            )
          : null,
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
                      asset: _iconTruckLoaded,
                      label: 'Volquete',
                    ),
                  ),
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
              if (_isOfflineMode || _errorMessage != null) ...[
                if (_isOfflineMode)
                  const _StatusBanner(
                    icon: Icons.cloud_off_outlined,
                    message:
                        'Operando sin conexión a Supabase. Los registros se guardarán de forma local.',
                  ),
                if (_errorMessage != null) ...[
                  if (_isOfflineMode) const SizedBox(height: 8),
                  _StatusBanner(
                    icon: Icons.info_outline,
                    message: _errorMessage!,
                  ),
                ],
                const SizedBox(height: 16),
              ],
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadVolquetes,
                  child: _isLoading
                      ? const _LoadingVolquetesView()
                      : _filteredVolquetes.isEmpty
                          ? const _EmptyVolquetesView()
                          : ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _filteredVolquetes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final volquete = _filteredVolquetes[index];
                                return _VolqueteCard(
                                  volquete: volquete,
                                  dateFormat: _dateFormat,
                                  onTap: () => _openDetail(volquete),
                                  onEdit: () => _openForm(initial: volquete),
                                  onViewDocument: () => _showSnack(
                                    'Documento ${volquete.documento ?? 'no disponible'}',
                                  ),
                                  onViewVolquete: () => _openDetail(volquete),
                                  onNavigate: () => _showSnack(
                                    'Navegando a ${volquete.destino}',
                                  ),
                                );
                              },
                            ),
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
    final theme = Theme.of(context);
    final subtle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.grey.shade500,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          'No se encontraron registros',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Ajusta los filtros o registra un nuevo volquete.',
            style: subtle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 160),
      ],
    );
  }
}

class _LoadingVolquetesView extends StatelessWidget {
  const _LoadingVolquetesView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 160),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background = scheme.secondaryContainer.withOpacity(0.25);
    final borderColor = scheme.outline.withOpacity(0.35);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
            ),
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
    required this.onViewDocument,
    required this.onViewVolquete,
    required this.onNavigate,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onViewDocument;
  final VoidCallback onViewVolquete;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final Color iconColor =
        Theme.of(context).iconTheme.color ?? Theme.of(context).colorScheme.onSurface;
    final bool isDescarga = volquete.tipo == VolqueteTipo.descarga;

    final List<_VolqueteCardAction> actions = isDescarga
        ? [
            _VolqueteCardAction(
              tooltip: 'Llegada al chute',
              asset: _iconTruckLoaded,
              onPressed: onViewVolquete,
            ),
            _VolqueteCardAction(
              tooltip: 'Fin de descarga',
              asset: _iconTruckEmpty,
              onPressed: onViewDocument,
            ),
            _VolqueteCardAction(
              tooltip: 'Maniobra de salida',
              asset: _iconArrowRight,
              onPressed: onNavigate,
            ),
            _VolqueteCardAction(
              tooltip: 'Editar',
              asset: _iconEditPen,
              onPressed: onEdit,
            ),
          ]
        : [
            _VolqueteCardAction(
              tooltip: 'Inicio de maniobra',
              asset: _iconArrowRight,
              onPressed: onViewVolquete,
            ),
            _VolqueteCardAction(
              tooltip: 'Inicio de carga',
              asset: _iconExcavatorCarga,
              onPressed: onViewDocument,
            ),
            _VolqueteCardAction(
              tooltip: 'Final de carga',
              asset: _iconExcavatorDescarga,
              onPressed: onNavigate,
            ),
            _VolqueteCardAction(
              tooltip: 'Editar',
              asset: _iconEditPen,
              onPressed: onEdit,
            ),
          ];

    Widget buildActionButton(_VolqueteCardAction action) {
      return IconButton(
        tooltip: action.tooltip,
        onPressed: action.onPressed,
        icon: SvgPicture.asset(
          action.asset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      );
    }

    Widget buildTrailing() {
      if (!isDescarga) {
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: actions.map(buildActionButton).toList(),
        );
      }

      final String estadoLabel =
          volquete.estado == VolqueteEstado.completo ? 'Completo' : 'Incompleto';

      Color estadoColor() {
        switch (volquete.estado) {
          case VolqueteEstado.completo:
            return Colors.green.shade600;
          case VolqueteEstado.enProceso:
            return Colors.orange.shade600;
          case VolqueteEstado.pausado:
            return Colors.blueGrey.shade600;
        }
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            estadoLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: estadoColor(),
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: actions.map(buildActionButton).toList(),
          ),
        ],
      );
    }

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
                        if (!isDescarga) ...[
                          const SizedBox(width: 12),
                          _EstadoChip(estado: volquete.estado),
                        ],
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
              buildTrailing(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolqueteCardAction {
  const _VolqueteCardAction({
    required this.tooltip,
    required this.asset,
    required this.onPressed,
  });

  final String tooltip;
  final String asset;
  final VoidCallback onPressed;
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
