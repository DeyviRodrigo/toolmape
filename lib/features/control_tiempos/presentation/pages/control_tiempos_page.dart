import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/viewmodels/control_tiempos_view_model.dart';
import 'package:toolmape/features/general/presentation/atoms/menu_option.dart';

/// Página: ControlTiemposPage - espacio para gestionar actividades y tiempos.
class ControlTiemposPage extends ConsumerStatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  ConsumerState<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

class _ControlTiemposPageState extends ConsumerState<ControlTiemposPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _searchController = TextEditingController();

    Future.microtask(
      () => ref.read(controlTiemposViewModelProvider.notifier).load(),
    );
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
    final equipo =
        _tabController.index == 0 ? VolqueteEquipo.cargador : VolqueteEquipo.excavadora;
    ref.read(controlTiemposViewModelProvider.notifier).changeEquipo(equipo);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref
          .read(controlTiemposViewModelProvider.notifier)
          .updateSearchTerm(value);
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

    final notifier = ref.read(controlTiemposViewModelProvider.notifier);
    notifier.upsertVolquete(result);

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

    final notifier = ref.read(controlTiemposViewModelProvider.notifier);

    if (result.deletedVolqueteId != null) {
      notifier.deleteVolquete(result.deletedVolqueteId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volquete eliminado')),
      );
      return;
    }

    if (result.updatedVolquete != null) {
      notifier.upsertVolquete(result.updatedVolquete!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Volquete actualizado')),
      );
    }
  }

  Future<void> _openEstadoFilterSheet() async {
    final result = await showModalBottomSheet<_EstadoFilterResult>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final selected =
            ref.read(controlTiemposViewModelProvider).estadoFilter;
        return _EstadoFilterSheet(
          selected: selected,
          onSelect: (value) => Navigator.of(context).pop(value),
        );
      },
    );

    if (!mounted || result == null) return;

    final notifier = ref.read(controlTiemposViewModelProvider.notifier);
    if (result.clear) {
      notifier.changeEstadoFilter(null);
    } else if (result.estado != null) {
      notifier.changeEstadoFilter(result.estado);
    }
  }

  void _showEstadoFilterSheet() {
    _openEstadoFilterSheet();
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    ref.read(controlTiemposViewModelProvider.notifier).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(controlTiemposViewModelProvider);
    final filteredVolquetes = state.filteredVolquetes;
    final selectedTipoIndex =
        state.selectedTipo == VolqueteTipo.carga ? 0 : 1;
    final tabIndex = state.selectedEquipo == VolqueteEquipo.cargador ? 0 : 1;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final estadoFilterLabel = state.estadoFilter?.label ?? 'Todos';
    if (_tabController.index != tabIndex) {
      _tabController.index = tabIndex;
    }

    return AppShell(
      title: 'Control de tiempos',
      actions: [
        MenuOption<VoidCallback>(
          value: () =>
              ref.read(controlTiemposViewModelProvider.notifier).refresh(),
          label: 'Refrescar',
          icon: Icons.refresh_rounded,
        ),
        MenuOption<VoidCallback>(
          value: _showEstadoFilterSheet,
          label: 'Filtrar por estado',
          icon: Icons.tune_rounded,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo volquete'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTipoIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: colors.primary,
        onDestinationSelected: (index) {
          final tipo = index == 0 ? VolqueteTipo.carga : VolqueteTipo.descarga;
          ref.read(controlTiemposViewModelProvider.notifier).changeTipo(tipo);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_upload_outlined),
            selectedIcon: Icon(Icons.cloud_upload),
            label: 'Carga',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download_outlined),
            selectedIcon: Icon(Icons.cloud_download),
            label: 'Descarga',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(
                    theme.brightness == Brightness.dark ? 0.2 : 0.7,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: colors.onPrimary,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  tabs: const [
                    Tab(text: 'Cargador'),
                    Tab(text: 'Excavadora'),
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
                      decoration: InputDecoration(
                        hintText: 'Buscar volquete…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: state.searchTerm.isEmpty
                            ? null
                            : IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.close_rounded),
                              ),
                        filled: true,
                        fillColor: colors.surfaceVariant.withOpacity(
                          theme.brightness == Brightness.dark ? 0.25 : 0.6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.tonalIcon(
                    onPressed: _showEstadoFilterSheet,
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(estadoFilterLabel),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.estadoFilter != null || state.searchTerm.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (state.estadoFilter != null)
                        InputChip(
                          avatar: Icon(
                            Icons.flag_rounded,
                            size: 18,
                            color: colors.primary,
                          ),
                          label:
                              Text('Estado: ${state.estadoFilter!.label}'),
                          onDeleted: () => ref
                              .read(controlTiemposViewModelProvider.notifier)
                              .changeEstadoFilter(null),
                        ),
                      if (state.searchTerm.isNotEmpty)
                        InputChip(
                          avatar: Icon(
                            Icons.search,
                            size: 18,
                            color: colors.primary,
                          ),
                          label: Text('Búsqueda: "${state.searchTerm}"'),
                          onDeleted: _clearSearch,
                        ),
                    ],
                  ),
                ),
              if (state.isLoading && state.volquetes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colors.primary),
                    backgroundColor:
                        colors.surfaceVariant.withOpacity(0.4),
                  ),
                ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (state.isLoading && state.volquetes.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.errorMessage != null && state.volquetes.isEmpty) {
                      return _ErrorView(message: state.errorMessage!);
                    }
                    if (filteredVolquetes.isEmpty) {
                      return const _EmptyVolquetesView();
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.outlineVariant.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              theme.brightness == Brightness.dark
                                  ? 0.3
                                  : 0.05,
                            ),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredVolquetes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final volquete = filteredVolquetes[index];
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: colors.surfaceVariant),
          const SizedBox(height: 16),
          Text(
            'No se encontraron registros',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta los filtros o registra un nuevo volquete.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 80, color: colors.error.withOpacity(0.8)),
          const SizedBox(height: 16),
          Text(
            'No se pudo cargar la información',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final metadata = <Widget>[
      _VolqueteMetadata(
        icon: Icons.directions_car_filled_outlined,
        label: volquete.placa,
      ),
      _VolqueteMetadata(
        icon: Icons.person_outline,
        label: volquete.operador,
      ),
      _VolqueteMetadata(
        icon: Icons.place_outlined,
        label: volquete.destino,
      ),
    ];

    if (volquete.documento != null) {
      metadata.add(
        _VolqueteMetadata(
          icon: Icons.picture_as_pdf_outlined,
          label: volquete.documento!,
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colors.outlineVariant.withOpacity(0.5),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: _estadoColor(colors),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            volquete.codigo,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _EstadoChip(estado: volquete.estado),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: metadata,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateFormat.format(volquete.fecha),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (volquete.notas != null && volquete.notas!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          volquete.notas!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VolqueteActionButton(
                    tooltip: 'Ver volquete',
                    icon: Icons.visibility_outlined,
                    onPressed: onViewVolquete,
                  ),
                  const SizedBox(height: 8),
                  _VolqueteActionButton(
                    tooltip: 'Ver documento',
                    icon: Icons.picture_as_pdf_outlined,
                    onPressed: onViewDocument,
                  ),
                  const SizedBox(height: 8),
                  _VolqueteActionButton(
                    tooltip: 'Navegar',
                    icon: Icons.route_outlined,
                    onPressed: onNavigate,
                  ),
                  const SizedBox(height: 8),
                  _VolqueteActionButton(
                    tooltip: 'Editar',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _estadoColor(ColorScheme colors) {
    switch (volquete.estado) {
      case VolqueteEstado.completo:
        return colors.primary;
      case VolqueteEstado.enProceso:
        return colors.secondary;
      case VolqueteEstado.pausado:
        return colors.tertiary;
    }
  }
}

class _VolqueteActionButton extends StatelessWidget {
  const _VolqueteActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: colors.surfaceVariant.withOpacity(
            theme.brightness == Brightness.dark ? 0.35 : 0.7,
          ),
        ),
      ),
    );
  }
}

class _VolqueteMetadata extends StatelessWidget {
  const _VolqueteMetadata({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(
          theme.brightness == Brightness.dark ? 0.28 : 0.6,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = _resolveColor(colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForEstado, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            estado.label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _iconForEstado {
    switch (estado) {
      case VolqueteEstado.completo:
        return Icons.check_circle_outline;
      case VolqueteEstado.enProceso:
        return Icons.timelapse;
      case VolqueteEstado.pausado:
        return Icons.pause_circle_outline;
    }
  }

  Color _resolveColor(ColorScheme colors) {
    switch (estado) {
      case VolqueteEstado.completo:
        return colors.primary;
      case VolqueteEstado.enProceso:
        return colors.secondary;
      case VolqueteEstado.pausado:
        return colors.tertiary;
    }
  }
}

class _EstadoFilterResult {
  const _EstadoFilterResult.value(this.estado)
      : clear = false;
  const _EstadoFilterResult.clear()
      : estado = null,
        clear = true;

  final VolqueteEstado? estado;
  final bool clear;
}

class _EstadoFilterOption {
  const _EstadoFilterOption({
    required this.label,
    required this.icon,
    this.estado,
    this.isClear = false,
  });

  final String label;
  final IconData icon;
  final VolqueteEstado? estado;
  final bool isClear;
}

class _EstadoFilterSheet extends StatelessWidget {
  const _EstadoFilterSheet({
    required this.selected,
    required this.onSelect,
  });

  final VolqueteEstado? selected;
  final ValueChanged<_EstadoFilterResult> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final options = const [
      _EstadoFilterOption(
        label: 'Todos',
        icon: Icons.all_inclusive,
        isClear: true,
      ),
      _EstadoFilterOption(
        label: 'Completo',
        icon: Icons.check_circle_outline,
        estado: VolqueteEstado.completo,
      ),
      _EstadoFilterOption(
        label: 'En proceso',
        icon: Icons.timelapse,
        estado: VolqueteEstado.enProceso,
      ),
      _EstadoFilterOption(
        label: 'Pausado',
        icon: Icons.pause_circle_outline,
        estado: VolqueteEstado.pausado,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtrar por estado',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...options.map((option) {
              final isSelected = option.isClear
                  ? selected == null
                  : selected == option.estado;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: isSelected
                      ? colors.primary.withOpacity(0.12)
                      : colors.surfaceVariant.withOpacity(
                          theme.brightness == Brightness.dark ? 0.25 : 0.6,
                        ),
                  leading: Icon(option.icon, color: colors.primary),
                  title: Text(option.label),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: colors.primary)
                      : null,
                  onTap: () {
                    if (option.isClear) {
                      onSelect(const _EstadoFilterResult.clear());
                    } else {
                      onSelect(_EstadoFilterResult.value(option.estado!));
                    }
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
