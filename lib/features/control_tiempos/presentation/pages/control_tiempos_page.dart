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
import 'package:toolmape/features/general/presentation/atoms/menu_option.dart';
import 'package:toolmape/core/theme/extensions/app_colors.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  final DateFormat _dateFormat = DateFormat('d/M/yyyy H:mm:ss');

  List<Volquete> _volquetes = const [];
  VolquetesSupabaseDatasource? _datasource;
  bool _isLoading = false;
  bool _isOfflineMode = false;
  String? _errorMessage;
  int _selectedBottomIndex = 0;
  String _searchTerm = '';
  Timer? _debounce;
  bool _isSelectionMode = false;
  final Set<String> _selectedVolquetes = <String>{};

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
    _searchFocusNode.dispose();
    _scrollController.dispose();
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
        _volquetes = _sortedVolquetes(_initialVolquetes);
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
        _volquetes = _sortedVolquetes(items);
        _isOfflineMode = false;
        _errorMessage = null;
      });
    } on VolquetesDatasourceException catch (error) {
      if (!mounted) return;
      setState(() {
        _volquetes = _sortedVolquetes(_initialVolquetes);
        _isOfflineMode = true;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _volquetes = _sortedVolquetes(_initialVolquetes);
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

  Future<void> _saveVolquete(
    Volquete volquete, {
    required bool isNew,
    String? successMessage,
  }) async {
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
        ..add(resolved);
      _volquetes = _sortedVolquetes(updatedList);
    });

    final defaultOnline =
        isNew ? 'Volquete registrado correctamente' : 'Volquete actualizado correctamente';
    final defaultOffline =
        isNew ? 'Volquete registrado sin conexión.' : 'Cambios guardados sin conexión.';

    final resolvedOnline = successMessage ?? defaultOnline;
    final resolvedOffline = successMessage != null
        ? '$successMessage (sin conexión)'
        : defaultOffline;

    _showSnack(offline ? resolvedOffline : resolvedOnline);

    if (isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _registerEvento(
    Volquete original, {
    required String titulo,
    required String descripcion,
    required String confirmationMessage,
    VolqueteEstado? nuevoEstado,
  }) async {
    final now = DateTime.now();
    final eventosActualizados = [
      ...original.eventos,
      VolqueteEvento(
        titulo: titulo,
        descripcion: descripcion,
        fecha: now,
      ),
    ];

    final actualizado = original.copyWith(
      eventos: eventosActualizados,
      estado: nuevoEstado ?? original.estado,
      fecha: now,
    );

    await _saveVolquete(
      actualizado,
      isNew: false,
      successMessage: confirmationMessage,
    );
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

  void _focusSearchField() {
    FocusScope.of(context).requestFocus(_searchFocusNode);
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

  void _startSelectionModeWith(Volquete volquete) {
    if (_isSelectionMode) return;
    setState(() {
      _isSelectionMode = true;
      _selectedVolquetes
        ..clear()
        ..add(volquete.id);
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

    return _sortedVolquetes(filtered);
  }

  List<Volquete> _sortedVolquetes(Iterable<Volquete> volquetes) {
    final sorted = volquetes.toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();

    return AppShell(
      title: 'Control de tiempos',
      actions: [
        MenuOption<VoidCallback>(
          value: _toggleSelectionMode,
          label: _isSelectionMode ? 'Cancelar selección' : 'Seleccionar',
          icon: _isSelectionMode ? Icons.close : Icons.select_all,
        ),
        MenuOption<VoidCallback>(
          value: _focusSearchField,
          label: 'Buscar',
          icon: Icons.search,
        ),
        MenuOption<VoidCallback>(
          value: () => _loadVolquetes(),
          label: 'Refrescar',
          icon: Icons.refresh,
        ),
      ],
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
                dividerColor: Colors.transparent,
                indicatorColor: scheme.primary,
                indicatorWeight: 3,
                labelColor: scheme.primary,
                unselectedLabelColor: theme.textTheme.bodyMedium?.color,
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
                focusNode: _searchFocusNode,
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
                              controller: _scrollController,
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: _filteredVolquetes.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (_, index) {
                                final volquete = _filteredVolquetes[index];
                                final isDescarga =
                                    volquete.tipo == VolqueteTipo.descarga;
                                final isSelected =
                                    _selectedVolquetes.contains(volquete.id);

                                late final VoidCallback primaryAction;
                                late final VoidCallback secondaryAction;
                                late final VoidCallback tertiaryAction;

                                if (isDescarga) {
                                  primaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Llegada al chute',
                                        descripcion:
                                            'El operador confirmó la llegada al punto de descarga.',
                                        confirmationMessage:
                                            'Llegada al chute registrada',
                                        nuevoEstado: VolqueteEstado.enProceso,
                                      );
                                  secondaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Fin de descarga',
                                        descripcion:
                                            'Se finalizó la descarga del material en el destino asignado.',
                                        confirmationMessage:
                                            'Fin de descarga registrado',
                                        nuevoEstado: VolqueteEstado.completo,
                                      );
                                  tertiaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Maniobra de salida',
                                        descripcion:
                                            'Se registró la maniobra de salida rumbo a la siguiente tarea.',
                                        confirmationMessage:
                                            'Maniobra de salida registrada',
                                        nuevoEstado: VolqueteEstado.completo,
                                      );
                                } else {
                                  primaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Inicio de maniobra',
                                        descripcion:
                                            'Se inició la maniobra previa a la carga en el frente asignado.',
                                        confirmationMessage:
                                            'Inicio de maniobra registrado',
                                        nuevoEstado: VolqueteEstado.enProceso,
                                      );
                                  secondaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Inicio de carga',
                                        descripcion:
                                            'Se registró el inicio de carga con el ${volquete.equipo.label.toLowerCase()}.',
                                        confirmationMessage:
                                            'Inicio de carga registrado',
                                        nuevoEstado: VolqueteEstado.enProceso,
                                      );
                                  tertiaryAction = () => _registerEvento(
                                        volquete,
                                        titulo: 'Final de carga',
                                        descripcion:
                                            'La carga fue completada y el volquete está listo para despacho.',
                                        confirmationMessage:
                                            'Final de carga registrado',
                                        nuevoEstado: VolqueteEstado.completo,
                                      );
                                }

                                VoidCallback cardTapCallback;
                                VoidCallback? longPressCallback;

                                if (_isSelectionMode) {
                                  cardTapCallback =
                                      () => _toggleVolqueteSelection(volquete);
                                } else {
                                  cardTapCallback =
                                      () => _openDetail(volquete);
                                  longPressCallback =
                                      () => _startSelectionModeWith(volquete);
                                }

                                return _VolqueteCard(
                                  volquete: volquete,
                                  dateFormat: _dateFormat,
                                  onTap: cardTapCallback,
                                  onLongPress: longPressCallback,
                                  onEdit: () => _openForm(initial: volquete),
                                  onPrimaryAction: primaryAction,
                                  onSecondaryAction: secondaryAction,
                                  onTertiaryAction: tertiaryAction,
                                  isSelectionMode: _isSelectionMode,
                                  isSelected: isSelected,
                                  onSelectionToggle: () =>
                                      _toggleVolqueteSelection(volquete),
                                  actionsEnabled: !_isSelectionMode,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final Color background = isSelected ? scheme.primary : scheme.surfaceVariant;
    final Color foreground = isSelected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: foreground.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
                style: theme.textTheme.labelLarge?.copyWith(
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
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.inbox_outlined,
          size: 64,
          color: theme.colorScheme.outline,
        ),
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
    this.onLongPress,
    required this.onEdit,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.onTertiaryAction,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onSelectionToggle,
    required this.actionsEnabled,
  });

  final Volquete volquete;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback onEdit;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;
  final VoidCallback onTertiaryAction;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onSelectionToggle;
  final bool actionsEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final Color iconColor = theme.iconTheme.color ?? scheme.onSurface;
    final subtleTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final appColors = theme.extension<AppColors>();
    final bool isDescarga = volquete.tipo == VolqueteTipo.descarga;

    bool hasEvento(String titulo) =>
        volquete.eventos.any((evento) => evento.titulo.toLowerCase() == titulo.toLowerCase());

    final List<_VolqueteCardAction> actions = isDescarga
        ? [
            _VolqueteCardAction(
              tooltip: 'Llegada al chute',
              asset: _iconTruckLoaded,
              onPressed: onPrimaryAction,
              isCompleted: hasEvento('Llegada al chute'),
            ),
            _VolqueteCardAction(
              tooltip: 'Fin de descarga',
              asset: _iconTruckEmpty,
              onPressed: onSecondaryAction,
              isCompleted: hasEvento('Fin de descarga'),
            ),
            _VolqueteCardAction(
              tooltip: 'Maniobra de salida',
              asset: _iconArrowRight,
              onPressed: onTertiaryAction,
              isCompleted: hasEvento('Maniobra de salida'),
            ),
            _VolqueteCardAction(
              tooltip: 'Editar',
              asset: _iconEditPen,
              onPressed: onEdit,
              isCompleted: false,
            ),
          ]
        : [
            _VolqueteCardAction(
              tooltip: 'Inicio de maniobra',
              asset: _iconArrowRight,
              onPressed: onPrimaryAction,
              isCompleted: hasEvento('Inicio de maniobra'),
            ),
            _VolqueteCardAction(
              tooltip: 'Inicio de carga',
              asset: _iconExcavatorCarga,
              onPressed: onSecondaryAction,
              isCompleted: hasEvento('Inicio de carga'),
            ),
            _VolqueteCardAction(
              tooltip: 'Final de carga',
              asset: _iconExcavatorDescarga,
              onPressed: onTertiaryAction,
              isCompleted: hasEvento('Final de carga'),
            ),
            _VolqueteCardAction(
              tooltip: 'Editar',
              asset: _iconEditPen,
              onPressed: onEdit,
              isCompleted: false,
            ),
          ];

    Widget buildActionButton(_VolqueteCardAction action) {
      return _VolqueteActionButton(
        tooltip: action.tooltip,
        asset: action.asset,
        onPressed: action.onPressed,
        iconColor: iconColor,
        isCompleted: action.isCompleted,
        enabled: actionsEnabled,
      );
    }

    String estadoLabel() {
      switch (volquete.estado) {
        case VolqueteEstado.completo:
          return 'Completo';
        case VolqueteEstado.enProceso:
          return 'Incompleto';
        case VolqueteEstado.pausado:
          return 'Pausado';
      }
    }

    Color estadoColor() {
      switch (volquete.estado) {
        case VolqueteEstado.completo:
          return appColors?.success ?? scheme.tertiary;
        case VolqueteEstado.enProceso:
          return appColors?.warning ?? scheme.secondary;
        case VolqueteEstado.pausado:
          return scheme.primary;
      }
    }

    Widget buildActions() {
      return Opacity(
        opacity: actionsEnabled ? 1 : 0.5,
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.end,
          children: actions.map(buildActionButton).toList(),
        ),
      );
    }

    Widget buildTrailing() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            estadoLabel(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: estadoColor(),
                ),
          ),
          const SizedBox(height: 8),
          buildActions(),
        ],
      );
    }

    final bool isDark = theme.brightness == Brightness.dark;
    final Color cardColor =
        Color.lerp(scheme.surface, scheme.surfaceVariant, isDark ? 0.7 : 0.2)!;
    final Color borderColor =
        scheme.outline.withOpacity(isDark ? 0.5 : 0.2);

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 4),
                  child: _SelectionIndicator(
                    selected: isSelected,
                    onTap: onSelectionToggle,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      volquete.codigo,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${volquete.placa} • ${volquete.operador}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(volquete.fecha),
                      style: subtleTextStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Destino: ${volquete.destino}',
                      style: subtleTextStyle,
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

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>();

    final Color activeColor = appColors?.success ?? scheme.primary;
    final Color borderColor = selected
        ? activeColor
        : scheme.outline.withOpacity(theme.brightness == Brightness.dark ? 0.6 : 0.4);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: 1.6),
            color: Colors.transparent,
          ),
          child: selected
              ? Center(
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: activeColor,
                  ),
                )
              : null,
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
    required this.isCompleted,
  });

  final String tooltip;
  final String asset;
  final VoidCallback onPressed;
  final bool isCompleted;
}

class _VolqueteActionButton extends StatelessWidget {
  const _VolqueteActionButton({
    required this.tooltip,
    required this.asset,
    required this.onPressed,
    required this.iconColor,
    required this.isCompleted,
    required this.enabled,
  });

  final String tooltip;
  final String asset;
  final VoidCallback onPressed;
  final Color iconColor;
  final bool isCompleted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final Color borderColor =
        isCompleted ? scheme.primary : theme.dividerColor.withOpacity(0.4);
    final Color resolvedIconColor =
        isCompleted ? scheme.primary : iconColor;

    final borderRadius = BorderRadius.circular(12);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        child: InkWell(
          borderRadius: borderRadius,
          onTap: enabled ? onPressed : null,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: borderColor),
            ),
            child: SvgPicture.asset(
              asset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                enabled
                    ? resolvedIconColor
                    : resolvedIconColor.withOpacity(0.4),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
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
