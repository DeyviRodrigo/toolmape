import 'package:flutter/material.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/application/control_tiempos_controller.dart';
import 'package:toolmape/features/control_tiempos/domain/models/control_tiempos_models.dart';

/// Página: ControlTiemposPage - espacio para gestionar actividades y tiempos.
class ControlTiemposPage extends StatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  State<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

class _ControlTiemposPageState extends State<ControlTiemposPage> {
  late final ControlTiemposController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ControlTiemposController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Control de Tiempos',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ToolMAPE – Sistema de Gestión Minera',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.colorScheme.surface,
              elevation: 4,
              child: TabBar(
                isScrollable: true,
                labelStyle: theme.textTheme.titleMedium,
                indicatorColor: theme.colorScheme.primary,
                tabs: _tabs
                    .map(
                      (tab) => Tab(
                        text: tab.label,
                        icon: Icon(tab.icon),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DashboardTab(controller: _controller),
                  _OperacionTab(
                    controller: _controller,
                    actividadId: 'act-carga',
                    filtroEquipo: null,
                  ),
                  _OperacionTab(
                    controller: _controller,
                    actividadId: 'act-descarga',
                    filtroEquipo: null,
                  ),
                  _OperacionTab(
                    controller: _controller,
                    filtroEquipo: TipoEquipo.cargador,
                  ),
                  _OperacionTab(
                    controller: _controller,
                    filtroEquipo: TipoEquipo.excavadora,
                  ),
                  _OperacionTab(
                    controller: _controller,
                    filtroEquipo: TipoEquipo.volquete,
                  ),
                  _CatalogosTab(controller: _controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.controller});

  final ControlTiemposController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<DashboardMetrics>(
      stream: controller.dashboardStream,
      builder: (context, snapshot) {
        final metrics = snapshot.data;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MetricCard(
                    title: 'Ciclo Promedio',
                    value: metrics == null
                        ? '--:--'
                        : _formatDuration(metrics.cicloPromedio),
                    subtitle: 'minutos',
                    icon: Icons.speed,
                  ),
                  const SizedBox(height: 16),
                  _MetricCard(
                    title: 'Ciclos Completados',
                    value: metrics?.ciclosCompletadosHoy.toString() ?? '0',
                    subtitle: 'hoy',
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(height: 16),
                  _MetricCard(
                    title: 'Equipos Activos',
                    value: metrics == null
                        ? '0'
                        : metrics.equiposActivos.values
                            .fold<int>(0, (a, b) => a + b)
                            .toString(),
                    subtitle: metrics == null
                        ? 'Sin actividad'
                        : metrics.equiposActivos.entries
                            .map((entry) =>
                                '${entry.value} ${tipoEquipoLabel(entry.key).toLowerCase()}${entry.value == 1 ? '' : 's'}')
                            .join(' · '),
                    icon: Icons.precision_manufacturing,
                  ),
                  const SizedBox(height: 16),
                  _MetricCard(
                    title: 'En Proceso',
                    value: metrics?.ciclosEnProceso.toString() ?? '0',
                    subtitle: 'ciclos abiertos',
                    icon: Icons.pending_actions,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tiempos de ciclo por equipo',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Ciclo>>(
                    stream: controller.ciclosStream,
                    builder: (context, snapshot) {
                      final ciclos = snapshot.data ?? [];
                      if (ciclos.isEmpty) {
                        return _EmptyState(
                          icon: Icons.query_stats,
                          message:
                              'Aún no hay registros de ciclos para mostrar en el dashboard.',
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ciclos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ciclo = ciclos[index];
                          final equipo = controller.equipoPorId(ciclo.equipoId);
                          final actividad =
                              controller.actividadPorId(ciclo.actividadId);
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.secondaryContainer,
                                child: Icon(
                                  Icons.timer,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                              title: Text(equipo?.nombre ?? 'Equipo sin nombre'),
                              subtitle: Text(
                                '${actividad?.nombre ?? 'Actividad'} · ${_formatDuration(ciclo.tiempoCalculado)}',
                              ),
                              trailing: Text(
                                ciclo.fin == null
                                    ? 'En curso'
                                    : _formatDateTime(ciclo.fin!),
                                style: theme.textTheme.labelMedium,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _OperacionTab extends StatefulWidget {
  const _OperacionTab({
    required this.controller,
    this.actividadId,
    this.filtroEquipo,
  });

  final ControlTiemposController controller;
  final String? actividadId;
  final TipoEquipo? filtroEquipo;

  @override
  State<_OperacionTab> createState() => _OperacionTabState();
}

class _OperacionTabState extends State<_OperacionTab> {
  late DateTime _selectedDate;
  String? _equipoId;
  String? _actividadId;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _actividadId = widget.actividadId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Ciclo>>(
      stream: widget.controller.ciclosStream,
      builder: (context, snapshot) {
        final ciclos = snapshot.data ?? [];
        final filteredCiclos = ciclos.where((ciclo) {
          final sameDay = DateUtils.isSameDay(ciclo.inicio, _selectedDate);
          if (!sameDay) return false;
          if (_equipoId != null && ciclo.equipoId != _equipoId) return false;
          final actividadFiltro = _actividadId ?? widget.actividadId;
          if (actividadFiltro != null && ciclo.actividadId != actividadFiltro) {
            return false;
          }
          if (widget.filtroEquipo != null) {
            final equipo = widget.controller.equipoPorId(ciclo.equipoId);
            if (equipo?.tipo != widget.filtroEquipo) return false;
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _FilterChip(
                    label: _dateLabel,
                    icon: Icons.today,
                    onPressed: _pickDate,
                  ),
                  StreamBuilder<List<Equipo>>(
                    stream: widget.controller.equiposStream,
                    builder: (context, equiposSnapshot) {
                      final equipos = equiposSnapshot.data ?? [];
                      final filtrados = widget.filtroEquipo == null
                          ? equipos
                          : equipos
                              .where((equipo) =>
                                  equipo.tipo == widget.filtroEquipo)
                              .toList();
                      return SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String?>(
                          value: _equipoId,
                          decoration: const InputDecoration(
                            labelText: 'Equipo',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            ...filtrados.map(
                              (equipo) => DropdownMenuItem(
                                value: equipo.id,
                                child: Text(equipo.nombre),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(() => _equipoId = value),
                        ),
                      );
                    },
                  ),
                  StreamBuilder<List<Actividad>>(
                    stream: widget.controller.actividadesStream,
                    builder: (context, actividadSnapshot) {
                      final actividades = actividadSnapshot.data ?? [];
                      return SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String?>(
                          value: _actividadId,
                          decoration: const InputDecoration(
                            labelText: 'Actividad',
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('Todas'),
                            ),
                            ...actividades.map(
                              (actividad) => DropdownMenuItem(
                                value: actividad.id,
                                child: Text(actividad.nombre),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(() => _actividadId = value),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar ciclo'),
                    onPressed: () => _showNuevoCicloForm(context),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Finalizar ciclo'),
                    onPressed: () => _showFinalizarCicloDialog(context),
                  ),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.pause_circle_outline),
                    label: const Text('Registrar pausa/tiempo muerto'),
                    onPressed: () => _showRegistrarPausaDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (filteredCiclos.isEmpty)
                _EmptyState(
                  icon: Icons.hourglass_empty,
                  message:
                      'No se han registrado ciclos en la fecha seleccionada.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCiclos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ciclo = filteredCiclos[index];
                    final equipo = widget.controller.equipoPorId(ciclo.equipoId);
                    final actividad =
                        widget.controller.actividadPorId(ciclo.actividadId);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 4,
                      child: ListTile(
                        title: Text(equipo?.nombre ?? 'Equipo sin nombre'),
                        subtitle: Text(
                          '${actividad?.nombre ?? 'Actividad'} · Inició ${_formatDateTime(ciclo.inicio)}',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _EstadoChip(estado: ciclo.estado),
                            const SizedBox(height: 6),
                            Text(
                              _formatDuration(ciclo.tiempoCalculado),
                              style: theme.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String get _dateLabel =>
      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _showNuevoCicloForm(BuildContext context) async {
    final equipos = await widget.controller.equiposStream.first;
    final actividades = await widget.controller.actividadesStream.first;
    final chutes = await widget.controller.chutesStream.first;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: _NuevoCicloForm(
            equipos: widget.filtroEquipo == null
                ? equipos
                : equipos
                    .where((equipo) => equipo.tipo == widget.filtroEquipo)
                    .toList(),
            actividades: actividades,
            chutes: chutes,
            onSubmit: (values) {
              try {
                widget.controller.iniciarCiclo(
                  equipoId: values.equipoId,
                  actividadId: values.actividadId,
                  chuteId: values.chuteId,
                  inicio: values.inicio,
                  fin: values.fin,
                  tiempoMuerto: values.tiempoMuerto,
                  observaciones: values.observaciones,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ciclo registrado correctamente.')),
                );
              } on ControlTiemposException catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error.message)),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _showFinalizarCicloDialog(BuildContext context) async {
    final ciclosEnProceso =
        (await widget.controller.ciclosStream.first).where((c) => c.estado == CicloEstado.enProceso).toList();
    if (ciclosEnProceso.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ciclos en proceso para finalizar.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => _FinalizarCicloDialog(
        ciclos: ciclosEnProceso,
        controller: widget.controller,
      ),
    );
  }

  Future<void> _showRegistrarPausaDialog(BuildContext context) async {
    final ciclosEnProceso =
        (await widget.controller.ciclosStream.first).where((c) => c.estado == CicloEstado.enProceso).toList();
    if (ciclosEnProceso.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ciclos en proceso para pausar.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => _RegistrarPausaDialog(
        ciclos: ciclosEnProceso,
        controller: widget.controller,
      ),
    );
  }
}

class _CatalogosTab extends StatelessWidget {
  const _CatalogosTab({required this.controller});

  final ControlTiemposController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CatalogSection<Equipo>(
            title: 'Equipos',
            icon: Icons.precision_manufacturing,
            stream: controller.equiposStream,
            itemBuilder: (context, equipo) => ListTile(
              title: Text(equipo.nombre),
              subtitle: Text('${equipo.codigo} · ${equipo.modelo}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: equipo.activo,
                    onChanged: (value) {
                      controller.upsertEquipo(
                        Equipo(
                          id: equipo.id,
                          codigo: equipo.codigo,
                          tipo: equipo.tipo,
                          nombre: equipo.nombre,
                          modelo: equipo.modelo,
                          activo: value,
                        ),
                      );
                    },
                  ),
                  _CatalogActionButton(
                    icon: Icons.edit,
                    tooltip: 'Editar',
                    onPressed: () => _showEquipoForm(context, equipo),
                  ),
                  _CatalogActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Eliminar',
                    onPressed: () => controller.eliminarEquipo(equipo.id),
                  ),
                ],
              ),
            ),
            onAdd: () => _showEquipoForm(context, null),
          ),
          const SizedBox(height: 32),
          _CatalogSection<Chute>(
            title: 'Chutes',
            icon: Icons.splitscreen,
            stream: controller.chutesStream,
            itemBuilder: (context, chute) => ListTile(
              title: Text(chute.nombre),
              subtitle: Text(chute.ubicacion),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CatalogActionButton(
                    icon: Icons.edit,
                    tooltip: 'Editar',
                    onPressed: () => _showChuteForm(context, chute),
                  ),
                  _CatalogActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Eliminar',
                    onPressed: () => controller.eliminarChute(chute.id),
                  ),
                ],
              ),
            ),
            onAdd: () => _showChuteForm(context, null),
          ),
          const SizedBox(height: 32),
          _CatalogSection<Actividad>(
            title: 'Actividades',
            icon: Icons.task_alt,
            stream: controller.actividadesStream,
            itemBuilder: (context, actividad) => ListTile(
              title: Text(actividad.nombre),
              subtitle: Text(actividad.abreviatura),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CatalogActionButton(
                    icon: Icons.edit,
                    tooltip: 'Editar',
                    onPressed: () => _showActividadForm(context, actividad),
                  ),
                  _CatalogActionButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Eliminar',
                    onPressed: () => controller.eliminarActividad(actividad.id),
                  ),
                ],
              ),
            ),
            onAdd: () => _showActividadForm(context, null),
          ),
        ],
      ),
    );
  }

  Future<void> _showEquipoForm(BuildContext context, Equipo? equipo) async {
    final controller = TextEditingController(text: equipo?.codigo ?? '');
    final nombreController = TextEditingController(text: equipo?.nombre ?? '');
    final modeloController = TextEditingController(text: equipo?.modelo ?? '');
    var tipo = equipo?.tipo ?? TipoEquipo.cargador;
    var activo = equipo?.activo ?? true;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(equipo == null ? 'Nuevo equipo' : 'Editar equipo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Código'),
                    ),
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: modeloController,
                      decoration:
                          const InputDecoration(labelText: 'Modelo/Placa'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TipoEquipo>(
                      value: tipo,
                      decoration: const InputDecoration(labelText: 'Tipo'),
                      items: TipoEquipo.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(tipoEquipoLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => tipo = value ?? tipo),
                    ),
                    SwitchListTile(
                      value: activo,
                      onChanged: (value) => setModalState(() => activo = value),
                      title: const Text('Activo'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.isEmpty ||
                        nombreController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Completa al menos el código y el nombre.'),
                        ),
                      );
                      return;
                    }
                    this.controller.upsertEquipo(
                          Equipo(
                            id: equipo?.id ??
                                this.controller.generarId(),
                            codigo: controller.text,
                            tipo: tipo,
                            nombre: nombreController.text,
                            modelo: modeloController.text,
                            activo: activo,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChuteForm(BuildContext context, Chute? chute) async {
    final nombreController = TextEditingController(text: chute?.nombre ?? '');
    final ubicacionController =
        TextEditingController(text: chute?.ubicacion ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chute == null ? 'Nuevo chute' : 'Editar chute'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: ubicacionController,
                  decoration: const InputDecoration(labelText: 'Ubicación'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nombreController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre es obligatorio.'),
                    ),
                  );
                  return;
                }
                this.controller.upsertChute(
                      Chute(
                        id: chute?.id ?? this.controller.generarId(),
                        nombre: nombreController.text,
                        ubicacion: ubicacionController.text,
                      ),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showActividadForm(
      BuildContext context, Actividad? actividad) async {
    final nombreController =
        TextEditingController(text: actividad?.nombre ?? '');
    final abreviaturaController =
        TextEditingController(text: actividad?.abreviatura ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(actividad == null ? 'Nueva actividad' : 'Editar actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: abreviaturaController,
                  decoration: const InputDecoration(labelText: 'Abreviatura'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (nombreController.text.isEmpty ||
                    abreviaturaController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Completa el nombre y la abreviatura.'),
                    ),
                  );
                  return;
                }
                this.controller.upsertActividad(
                      Actividad(
                        id: actividad?.id ?? this.controller.generarId(),
                        nombre: nombreController.text,
                        abreviatura: abreviaturaController.text,
                      ),
                    );
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _NuevoCicloFormValues {
  _NuevoCicloFormValues({
    required this.equipoId,
    required this.actividadId,
    this.chuteId,
    required this.inicio,
    this.fin,
    this.tiempoMuerto,
    this.observaciones,
  });

  final String equipoId;
  final String actividadId;
  final String? chuteId;
  final DateTime inicio;
  final DateTime? fin;
  final Duration? tiempoMuerto;
  final String? observaciones;
}

class _NuevoCicloForm extends StatefulWidget {
  const _NuevoCicloForm({
    required this.equipos,
    required this.actividades,
    required this.chutes,
    required this.onSubmit,
  });

  final List<Equipo> equipos;
  final List<Actividad> actividades;
  final List<Chute> chutes;
  final ValueChanged<_NuevoCicloFormValues> onSubmit;

  @override
  State<_NuevoCicloForm> createState() => _NuevoCicloFormState();
}

class _NuevoCicloFormState extends State<_NuevoCicloForm> {
  final _formKey = GlobalKey<FormState>();
  String? _equipoId;
  String? _actividadId;
  String? _chuteId;
  DateTime _inicio = DateTime.now();
  DateTime? _fin;
  Duration? _tiempoMuerto;
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _tiempoMuertoController = TextEditingController();

  @override
  void dispose() {
    _observacionesController.dispose();
    _tiempoMuertoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _equipoId,
            decoration: const InputDecoration(labelText: 'Maquinaria'),
            items: widget.equipos
                .map(
                  (equipo) => DropdownMenuItem(
                    value: equipo.id,
                    child: Text(equipo.nombre),
                  ),
                )
                .toList(),
            validator: (value) => value == null ? 'Selecciona un equipo' : null,
            onChanged: (value) => setState(() => _equipoId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value: _chuteId,
            decoration: const InputDecoration(labelText: 'Chute (opcional)'),
            items: [
              const DropdownMenuItem<String?>(
                  value: null, child: Text('Ninguno')),
              ...widget.chutes.map(
                (chute) => DropdownMenuItem(
                  value: chute.id,
                  child: Text(chute.nombre),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _chuteId = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _actividadId,
            decoration: const InputDecoration(labelText: 'Actividad'),
            items: widget.actividades
                .map(
                  (actividad) => DropdownMenuItem(
                    value: actividad.id,
                    child: Text(actividad.nombre),
                  ),
                )
                .toList(),
            validator: (value) =>
                value == null ? 'Selecciona una actividad' : null,
            onChanged: (value) => setState(() => _actividadId = value),
          ),
          const SizedBox(height: 12),
          _DateTimePickerField(
            label: 'Inicio',
            value: _inicio,
            onChanged: (value) => setState(() {
              if (value != null) {
                _inicio = value;
              }
            }),
          ),
          const SizedBox(height: 12),
          _DateTimePickerField(
            label: 'Final (opcional)',
            value: _fin,
            onChanged: (value) => setState(() => _fin = value),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tiempoMuertoController,
            decoration: const InputDecoration(
              labelText: 'Tiempo muerto (minutos, opcional)',
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => setState(() {
              if (value.isEmpty) {
                _tiempoMuerto = null;
              } else {
                final parsed = int.tryParse(value);
                _tiempoMuerto = parsed == null
                    ? null
                    : Duration(minutes: parsed);
              }
            }),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(labelText: 'Observaciones'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _ReadOnlyField(
            label: 'Tiempo calculado',
            value: _fin == null
                ? 'En curso'
                : _formatDuration(_fin!.difference(_inicio)),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                if (_fin != null && _fin!.isBefore(_inicio)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'La fecha final no puede ser menor a la inicial.',
                      ),
                    ),
                  );
                  return;
                }
                if (_tiempoMuerto != null && _fin != null) {
                  final calculado = _fin!.difference(_inicio);
                  if (_tiempoMuerto! > calculado) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'El tiempo muerto no puede exceder al calculado.',
                        ),
                      ),
                    );
                    return;
                  }
                }
                widget.onSubmit(
                  _NuevoCicloFormValues(
                    equipoId: _equipoId!,
                    actividadId: _actividadId!,
                    chuteId: _chuteId,
                    inicio: _inicio,
                    fin: _fin,
                    tiempoMuerto: _tiempoMuerto,
                    observaciones: _observacionesController.text,
                  ),
                );
              },
              child: const Text('Guardar ciclo'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.label,
    required this.onChanged,
    this.value,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final initial = value ?? DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (date == null) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (time == null) return;
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(dateTime);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null
                  ? 'Seleccionar'
                  : _formatDateTime(value!),
              style: theme.textTheme.bodyMedium,
            ),
            const Icon(Icons.calendar_month),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Text(value),
    );
  }
}

class _FinalizarCicloDialog extends StatefulWidget {
  const _FinalizarCicloDialog({
    required this.ciclos,
    required this.controller,
  });

  final List<Ciclo> ciclos;
  final ControlTiemposController controller;

  @override
  State<_FinalizarCicloDialog> createState() => _FinalizarCicloDialogState();
}

class _FinalizarCicloDialogState extends State<_FinalizarCicloDialog> {
  String? _cicloId;
  DateTime _fin = DateTime.now();
  final TextEditingController _tiempoMuertoController = TextEditingController();

  @override
  void dispose() {
    _tiempoMuertoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finalizar ciclo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String?>(
              value: _cicloId,
              decoration: const InputDecoration(labelText: 'Ciclo'),
              items: widget.ciclos
                  .map(
                    (ciclo) => DropdownMenuItem(
                      value: ciclo.id,
                      child: Text('${ciclo.id.substring(0, 6)} - ${_formatDateTime(ciclo.inicio)}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _cicloId = value),
            ),
            const SizedBox(height: 12),
            _DateTimePickerField(
              label: 'Finalización',
              value: _fin,
              onChanged: (value) => setState(() => _fin = value ?? _fin),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tiempoMuertoController,
              decoration: const InputDecoration(
                labelText: 'Tiempo muerto (minutos, opcional)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_cicloId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona un ciclo.')),
              );
              return;
            }
            try {
              widget.controller.finalizarCiclo(
                cicloId: _cicloId!,
                fin: _fin,
                tiempoMuerto: _parseDuration(_tiempoMuertoController.text),
              );
              Navigator.of(context).pop();
            } on ControlTiemposException catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            }
          },
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}

class _RegistrarPausaDialog extends StatefulWidget {
  const _RegistrarPausaDialog({
    required this.ciclos,
    required this.controller,
  });

  final List<Ciclo> ciclos;
  final ControlTiemposController controller;

  @override
  State<_RegistrarPausaDialog> createState() => _RegistrarPausaDialogState();
}

class _RegistrarPausaDialogState extends State<_RegistrarPausaDialog> {
  String? _cicloId;
  final TextEditingController _tiempoMuertoController = TextEditingController();

  @override
  void dispose() {
    _tiempoMuertoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar pausa'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String?>(
            value: _cicloId,
            decoration: const InputDecoration(labelText: 'Ciclo'),
            items: widget.ciclos
                .map(
                  (ciclo) => DropdownMenuItem(
                    value: ciclo.id,
                    child: Text('${ciclo.id.substring(0, 6)} - ${_formatDateTime(ciclo.inicio)}'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _cicloId = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tiempoMuertoController,
            decoration: const InputDecoration(
              labelText: 'Tiempo muerto (minutos)',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_cicloId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecciona un ciclo.')),
              );
              return;
            }
            try {
              widget.controller.registrarPausa(
                cicloId: _cicloId!,
                tiempoMuerto: _parseDuration(
                      _tiempoMuertoController.text,
                    ) ??
                    Duration.zero,
              );
              Navigator.of(context).pop();
            } on ControlTiemposException catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message)),
              );
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final CicloEstado estado;

  @override
  Widget build(BuildContext context) {
    final color = estadoChipColor(context, estado);
    final label = switch (estado) {
      CicloEstado.enProceso => 'En proceso',
      CicloEstado.pausado => 'Pausado',
      CicloEstado.completado => 'Completado',
    };
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(label),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CatalogSection<T> extends StatelessWidget {
  const _CatalogSection({
    required this.title,
    required this.icon,
    required this.stream,
    required this.itemBuilder,
    required this.onAdd,
  });

  final String title;
  final IconData icon;
  final Stream<List<T>> stream;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  onPressed: onAdd,
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<T>>(
              stream: stream,
              builder: (context, snapshot) {
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _EmptyState(
                    icon: Icons.inbox_outlined,
                    message: 'No hay registros disponibles.',
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => itemBuilder(context, items[index]),
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: items.length,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogActionButton extends StatelessWidget {
  const _CatalogActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _TabDefinition {
  const _TabDefinition({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

const _tabs = <_TabDefinition>[
  _TabDefinition(label: 'Dashboard', icon: Icons.dashboard),
  _TabDefinition(label: 'Carga', icon: Icons.upload),
  _TabDefinition(label: 'Descarga', icon: Icons.download),
  _TabDefinition(label: 'Cargador', icon: Icons.electric_bolt),
  _TabDefinition(label: 'Excavadora', icon: Icons.construction),
  _TabDefinition(label: 'Volquete', icon: Icons.local_shipping),
  _TabDefinition(label: 'Catálogos', icon: Icons.location_on),
];

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).abs().toString().padLeft(2, '0');
  final hours = duration.inHours.abs();
  final seconds = duration.inSeconds.remainder(60).abs().toString().padLeft(2, '0');
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

String _formatDateTime(DateTime dateTime) {
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

Duration? _parseDuration(String value) {
  if (value.trim().isEmpty) return null;
  final minutes = int.tryParse(value.trim());
  if (minutes == null) return null;
  return Duration(minutes: minutes);
}
