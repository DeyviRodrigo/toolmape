import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/models/registro_tiempo.dart';
import 'package:toolmape/features/control_tiempos/presentation/controllers/control_tiempos_controller.dart';
import 'package:toolmape/features/control_tiempos/presentation/screens/detalle_registro_screen.dart';
import 'package:toolmape/features/control_tiempos/presentation/screens/formulario_registro_screen.dart';
import 'package:toolmape/theme/app_colors.dart';

class ControlTiemposScreen extends ConsumerStatefulWidget {
  const ControlTiemposScreen({super.key});

  @override
  ConsumerState<ControlTiemposScreen> createState() =>
      _ControlTiemposScreenState();
}

class _ControlTiemposScreenState extends ConsumerState<ControlTiemposScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(controlTiemposControllerProvider.notifier).cargar();
    });

    ref.listen<ControlTiemposState>(
      controlTiemposControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              action: SnackBarAction(
                label: 'Reintentar',
                onPressed: () =>
                    ref.read(controlTiemposControllerProvider.notifier).cargar(),
              ),
            ),
          );
        }
      },
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
    ref
        .read(controlTiemposControllerProvider.notifier)
        .setTab(_tabController.index);
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(controlTiemposControllerProvider.notifier).onSearch(value);
    });
  }

  Future<void> _onRefresh() {
    return ref.read(controlTiemposControllerProvider.notifier).cargar();
  }

  Future<void> _verDetalle(RegistroTiempo registro) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleRegistroScreen(registroId: registro.id),
      ),
    );
    if (!mounted) return;
    await ref.read(controlTiemposControllerProvider.notifier).cargar();
  }

  Future<void> _editar(RegistroTiempo registro) async {
    final state = ref.read(controlTiemposControllerProvider);
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioRegistroScreen(
          modo: RegistroModo.edicion,
          registro: registro,
          equipoTipo: state.equipoActual,
          operacion: state.operacion,
        ),
      ),
    );
    if (shouldRefresh == true && mounted) {
      await ref.read(controlTiemposControllerProvider.notifier).cargar();
    }
  }

  Future<void> _abrirNuevo() async {
    final state = ref.read(controlTiemposControllerProvider);
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioRegistroScreen(
          modo: RegistroModo.creacion,
          equipoTipo: state.equipoActual,
          operacion: state.operacion,
        ),
      ),
    );
    if (shouldRefresh == true && mounted) {
      await ref.read(controlTiemposControllerProvider.notifier).cargar();
    }
  }

  Future<void> _verDocumento(RegistroTiempo registro) async {
    final service = ref.read(controlTiemposControllerProvider.notifier).service;
    await service.generarPdf(registro);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          registro.documento == null
              ? 'Documento no disponible'
              : 'Generando ${registro.documento}',
        ),
      ),
    );
  }

  void _navegar(RegistroTiempo registro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navegando hacia ${registro.destino}...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(controlTiemposControllerProvider);
    final registros = state.filtrados;
    final dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Control de Tiempos CI-F1'),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: const [
          Icon(Icons.tune_rounded),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _abrirNuevo,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.operacion == RegistroOperacion.carga ? 0 : 1,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white70,
        onTap: (index) => ref
            .read(controlTiemposControllerProvider.notifier)
            .setOperacion(index == 0
                ? RegistroOperacion.carga
                : RegistroOperacion.descarga),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_rounded),
            label: 'Carga',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded),
            label: 'Descarga',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(
                  icon: Icon(Icons.construction),
                  text: 'Cargador',
                ),
                Tab(
                  icon: Icon(Icons.engineering),
                  text: 'Excavadora',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar volquete…',
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: AppColors.surfaceLight,
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.clear, color: Colors.white70),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              backgroundColor: AppColors.surface,
              color: AppColors.primary,
              child: Builder(
                builder: (context) {
                  if (state.isLoading && registros.isEmpty) {
                    return const _LoadingView();
                  }
                  if (registros.isEmpty) {
                    return const _EmptyView();
                  }
                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (_, index) {
                      final registro = registros[index];
                      return _RegistroCard(
                        registro: registro,
                        dateFormat: dateFormat,
                        onTap: () => _verDetalle(registro),
                        onVerVolquete: () => _verDetalle(registro),
                        onVerDocumento: () => _verDocumento(registro),
                        onNavegar: () => _navegar(registro),
                        onEditar: () => _editar(registro),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: registros.length,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistroCard extends StatelessWidget {
  const _RegistroCard({
    required this.registro,
    required this.dateFormat,
    required this.onTap,
    required this.onVerVolquete,
    required this.onVerDocumento,
    required this.onNavegar,
    required this.onEditar,
  });

  final RegistroTiempo registro;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final VoidCallback onVerVolquete;
  final VoidCallback onVerDocumento;
  final VoidCallback onNavegar;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🚛', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registro.volquete,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${registro.operador} • ${registro.destino}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _EstadoChip(estado: registro.estado),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.white54),
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(registro.fechaReferencia),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  Text(
                    registro.operacion.label,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _IconAction(
                    icon: Icons.visibility_outlined,
                    label: 'Ver',
                    onPressed: onVerVolquete,
                  ),
                  _IconAction(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Doc',
                    onPressed: onVerDocumento,
                  ),
                  _IconAction(
                    icon: Icons.navigation_outlined,
                    label: 'Ruta',
                    onPressed: onNavegar,
                  ),
                  _IconAction(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    onPressed: onEditar,
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

  final RegistroEstado estado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estado.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: estado.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            estado.label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Icon(Icons.inbox_outlined, size: 64, color: Colors.white30),
        ),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No se encontraron registros',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        SizedBox(height: 4),
        Center(
          child: Text(
            'Ajusta los filtros o crea un nuevo registro.',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 140),
        Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ],
    );
  }
}
