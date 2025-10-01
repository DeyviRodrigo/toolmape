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
    if (_tabController.index != tabIndex) {
      _tabController.index = tabIndex;
    }

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTipoIndex,
        onDestinationSelected: (index) {
          final tipo = index == 0 ? VolqueteTipo.carga : VolqueteTipo.descarga;
          ref.read(controlTiemposViewModelProvider.notifier).changeTipo(tipo);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_upload_outlined),
            label: 'Carga',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download_outlined),
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
                  suffixIcon: state.searchTerm.isEmpty
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
                    return ListView.separated(
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            'No se pudo cargar la información',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
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
                spacing: 4,
                runSpacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Ver volquete',
                    onPressed: onViewVolquete,
                    icon: const Icon(Icons.visibility_outlined),
                  ),
                  IconButton(
                    tooltip: 'Ver documento',
                    onPressed: onViewDocument,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  IconButton(
                    tooltip: 'Navegar',
                    onPressed: onNavigate,
                    icon: const Icon(Icons.route_outlined),
                  ),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
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
