import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:table_calendar/table_calendar.dart';

import '../../app_shell.dart';
import '../../core/notifications/calendario_notifications.dart';
import '../../presentation/providers/calendario_providers.dart';
import '../../presentation/providers/mis_eventos_providers.dart';
import '../../init_dependencies.dart';
import '../../domain/value_objects/date_range_entity.dart';
import '../../routes.dart';
import '../../domain/usecases/schedule_notifications_usecase.dart';
import 'eventos_calendario.dart';
import '../../presentation/viewmodels/calendario_view_model.dart';
import '../../presentation/shared/event_filter.dart';

// Eventos privados del usuario
import 'mi_evento.dart';

/// Clase: _Marker - marcador para el calendario (icono + color).
class _Marker {
  final IconData icon;
  final Color color;
  const _Marker(this.icon, this.color);
}

/// Widget: CalendarioMineroScreen - pantalla principal del calendario.
class CalendarioMineroScreen extends ConsumerStatefulWidget {
  const CalendarioMineroScreen({super.key});
  @override
  ConsumerState<CalendarioMineroScreen> createState() => _CalendarioMineroScreenState();
}

/// State: _CalendarioMineroScreenState - maneja la lógica del calendario.
class _CalendarioMineroScreenState extends ConsumerState<CalendarioMineroScreen> {

  // Getter: _mesClave - clave del mes enfocado.
  DateTime get _mesClave => DateTime(_focused.year, _focused.month, 1);

  // Estado del calendario
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  EventFilter _filtro = EventFilter.all;

  // Getter: _mesRango - rango visible del mes para cargar "mis eventos".
  DateTimeRange get _mesRango {
    final first = DateTime(_focused.year, _focused.month, 1);
    final last = DateTime(_focused.year, _focused.month + 1, 0);
    return DateTimeRange(
      start: first,
      end: DateTime(last.year, last.month, last.day, 23, 59, 59),
    );
  }

  // ---- Helpers de estilo / lógica ----

  // Función: _calendarHeight - altura estable del calendario.
  double _calendarHeight(BuildContext ctx) {
    final h = MediaQuery.of(ctx).size.height;
    if (h < 650) return 300;
    if (h < 800) return 360;
    return 400;
  }

  // Función: _cellRectBorder - borde cuadriculado de cada celda.
  BoxDecoration _cellRectBorder(BuildContext ctx, {Color? color}) => BoxDecoration(
    shape: BoxShape.rectangle,
    border: Border.all(color: color ?? Colors.grey.shade300, width: 0.6),
  );

  // Función: _cellRectFilled - celda con relleno y borde.
  BoxDecoration _cellRectFilled(BuildContext ctx, {required Color bg, Color? border}) {
    return BoxDecoration(
      shape: BoxShape.rectangle,
      color: bg,
      border: Border.all(color: border ?? Colors.grey.shade300, width: 0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventosAsync = ref.watch(eventosMesProvider(_mesClave));

    final userEventosAsync = ref.watch(
      misEventosRangoProvider(
        DateRange(start: _mesRango.start, end: _mesRango.end),
      ),
    );
    final vm = ref.read(calendarioViewModelProvider.notifier);

    return AppShell(
      title: 'Calendario minero',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      actions: [
        // Filtro
        PopupMenuButton<EventFilter>(
          tooltip: 'Filtrar',
          icon: const Icon(Icons.filter_list),
          onSelected: (f) => setState(() => _filtro = f),
          itemBuilder: (_) => [
            _itemFiltro(EventFilter.all, 'Todo', Icons.layers, _filtro),
            _itemFiltro(EventFilter.general, 'Obligaciones', Icons.assignment_outlined, _filtro),
            _itemFiltro(EventFilter.personal, 'Mis eventos', Icons.event, _filtro),
          ],
        ),
        IconButton(
          tooltip: 'Programar recordatorios',
          icon: const Icon(Icons.notifications_active_outlined),
          onPressed: () async {
            final events = await ref.read(eventosMesProvider(_focused).future);
            final schedule = ScheduleNotifications(
              cancelAll: CalendarioNotifications.cancelAll,
              scheduleOnce: CalendarioNotifications.scheduleOnce,
            );
            await schedule(
              eventos: events,
              rucLastDigit: null,
              regimen: null,
              isWeb: kIsWeb,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones programadas')),
              );
            }
          },
        ),
        // Nuevo evento (privado)
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Nuevo evento',
          onPressed: () async {
            final repo = ref.read(misEventosRepositoryProvider);
            if (repo.anonDisabled) {
              if (mounted) {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Eventos privados desactivados'),
                    content: Text('Activa Anonymous sign-in en Supabase (Auth → Providers) para guardar tus eventos personales.'),
                  ),
                );
              }
              return;
            }
            final ok = await _nuevoEventoDialog(context);
            if (ok == true) {
              ref.invalidate(
                misEventosRangoProvider(
                  DateRange(start: _mesRango.start, end: _mesRango.end),
                ),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Evento guardado')),
                );
              }
            }
          },
        ),

        IconButton(
          tooltip: 'Actualizar calendario',
          icon: const Icon(Icons.sync),
          onPressed: () async {
            final mes = DateTime(_focused.year, _focused.month, 1);
            ref.invalidate(eventosMesProvider(mes));
            await ref.read(eventosMesProvider(mes).future);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calendario actualizado')),
              );
            }
          },
        ),

      ],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const SizedBox(height: 12),            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Calendario mensual (cuadriculado + marcadores + feriados)
                    SizedBox(
                      height: _calendarHeight(context),
                      child: TableCalendar(
                        firstDay: DateTime(2020, 1, 1),
                        lastDay: DateTime(2030, 12, 31),
                        focusedDay: _focused,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        locale: 'es_ES',
                        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                        calendarFormat: CalendarFormat.month,
                        selectedDayPredicate: (d) => isSameDay(d, _selected),
                        onDaySelected: (sel, foc) => setState(() { _selected = sel;}),
                        onPageChanged: (foc) => setState(() { _focused = foc; }),

                        // feriados en rojo (usa fecha de vencimiento)
                        holidayPredicate: (day) {
                          final evs = eventosAsync.value ?? const <EventoCalendar>[];
                          return evs.any((e) => vm.esFeriado(e) && isSameDay(vm.fechaVenc(e), day));
                        },

                        // cuadriculado
                        calendarStyle: CalendarStyle(
                          cellMargin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),

                          outsideDaysVisible: true,
                          isTodayHighlighted: true,

                          // Cuadriculado base
                          defaultDecoration: _cellRectBorder(context),
                          weekendDecoration: _cellRectBorder(context),
                          outsideDecoration: _cellRectBorder(context, color: Colors.grey.shade200),

                          // "Hoy" cuando no está seleccionado
                          todayDecoration: _cellRectFilled(
                            context,
                            bg: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.18),
                            border: Colors.grey.shade400,
                          ),
                          todayTextStyle: const TextStyle(fontWeight: FontWeight.w700),

                          // Seleccionado (como ya lo tenías, pero con el helper de fill)
                          selectedDecoration: _cellRectFilled(
                            context,
                            bg: Theme.of(context).colorScheme.secondaryContainer,
                            border: Theme.of(context).colorScheme.secondary,
                          ),
                          selectedTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),

                          // Feriados en rojo
                          holidayDecoration: const BoxDecoration(
                            color: Color(0xFFD32F2F),
                            shape: BoxShape.rectangle,
                          ),
                          holidayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),

                          markersAlignment: Alignment.bottomCenter,
                        ),

                        // eventos → marcadores
                        eventLoader: (day) {
                          final generales = (eventosAsync.value ?? [])
                              .where((e) {
                            final f = vm.fechaVenc(e);
                            return f != null && isSameDay(f, day) && !vm.esFeriado(e);
                          })
                              .map((e) => _Marker(vm.iconoPara(e), Colors.amber.shade800));

                          final propios = (userEventosAsync.value ?? [])
                              .where((e) => isSameDay(e.inicio, day))
                              .map((_) => const _Marker(Icons.event, Colors.blue));

                          final List<_Marker> list = [];
                          if (_filtro == EventFilter.all || _filtro == EventFilter.general) list.addAll(generales);
                          if (_filtro == EventFilter.all || _filtro == EventFilter.personal) list.addAll(propios);
                          return list;
                        },

                        calendarBuilders: CalendarBuilders(
                          // iconitos abajo
                          markerBuilder: (context, day, events) {
                            final items = events
                                .whereType<_Marker>()
                                .take(4)
                                .map<Widget>((m) => Icon(m.icon, size: 12, color: m.color))
                                .toList();

                            if (items.isEmpty) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Wrap(
                                spacing: 2,
                                runSpacing: 2,
                                alignment: WrapAlignment.center,
                                children: items,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Leyenda (responsive)
                    const _Legend(),
                    const SizedBox(height: 8),

                    // Lista del día seleccionado (unificada + filtro)
                    Builder(
                      builder: (_) {
                        final genAll = (eventosAsync.value ?? [])
                            .where((e) {
                            final f = vm.fechaVenc(e);
                          return f != null && isSameDay(f, _selected);
                        })
                            .toList();

                        final usrAll = (userEventosAsync.value ?? [])
                            .where((e) => isSameDay(e.inicio, _selected))
                            .toList();

                        final generales = (_filtro == EventFilter.personal) ? <EventoCalendar>[] : genAll;
                        final propios   = (_filtro == EventFilter.general)  ? <MiEvento>[]       : usrAll;

                        if (generales.isEmpty && propios.isEmpty) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text('Sin eventos para este día'),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (generales.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(left: 4, top: 6),
                                child: Text('Eventos para hoy', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ...generales.map((e) {
                              final f = vm.fechaVenc(e)!; // vencimiento
                              final fechaStr = '${f.day.toString().padLeft(2,'0')}/${f.month.toString().padLeft(2,'0')}';
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.assignment_outlined),
                                title: Text(e.titulo),
                                subtitle: Text('${e.categoria ?? ''} • Vence: $fechaStr'),
                                onTap: () {
                                  showDialog(context: context, builder: (_) {
                                    return AlertDialog(
                                      title: Text(e.titulo),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if ((e.descripcion ?? '').isNotEmpty) Text(e.descripcion!),
                                          const SizedBox(height: 8),
                                          Text('Vencimiento: ${e.fin?.toString().substring(0,10) ?? '-'}'),
                                          Text('Inicio período: ${e.inicio?.toString().substring(0,10) ?? '-'}'),
                                          Text('Recordatorio: ${e.recordatorio?.toString().substring(0,10) ?? '-'}'),
                                          if ((e.fuente ?? '').isNotEmpty) Text('Fuente: ${e.fuente}'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cerrar')),
                                      ],
                                    );
                                  });
                                },
                              );
                            }),
                            if (propios.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.only(left: 4, top: 6),
                                child: Text('Mis eventos', style: TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ...propios.map((e) {
                              final hora = e.allDay
                                  ? 'Todo el día'
                                  : '${e.inicio.hour.toString().padLeft(2,'0')}:${e.inicio.minute.toString().padLeft(2,'0')}';
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.event),
                                title: Text(e.titulo),
                                subtitle: Text(hora),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await ref.read(misEventosRepositoryProvider).borrar(e.id);
                                    ref.invalidate(
                                      misEventosRangoProvider(
                                        DateRange(start: _mesRango.start, end: _mesRango.end),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Resumen por mes (NO scroll propio, hereda del padre)
                    eventosAsync.when(
                      data: (list) {
                        if (list.isEmpty) return const Center(child: Text('Sin eventos para este mes'));

                        final grupos = <int, List<EventoCalendar>>{};
                        for (final e in list) {
                          final f = vm.fechaVenc(e);
                          if (f == null) continue;
                          grupos.putIfAbsent(f.month, () => []).add(e);
                        }
                        final meses = grupos.keys.toList()..sort();

                        return Column(
                          children: meses.map((mes) {
                            final items = grupos[mes]!..sort((a, b) => vm.fechaVenc(a)!.compareTo(vm.fechaVenc(b)!));
                            return ExpansionTile(
                              title: Text(vm.mesNombrePublic(mes), style: const TextStyle(fontWeight: FontWeight.w600)),
                              children: items.map((e) {
                                final f = vm.fechaVenc(e)!;
                                final fechaStr = '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}';

                                return ListTile(
                                  title: Text(e.titulo),
                                  subtitle: Text('${e.categoria ?? ''}  •  $fechaStr'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    showDialog(context: context, builder: (_) {
                                      return AlertDialog(
                                        title: Text(e.titulo),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if ((e.descripcion ?? '').isNotEmpty) Text(e.descripcion!),
                                            const SizedBox(height: 8),
                                            Text('Vencimiento: ${e.fin?.toString().substring(0,10) ?? '-'}'),
                                            Text('Inicio período: ${e.inicio?.toString().substring(0,10) ?? '-'}'),
                                            Text('Recordatorio: ${e.recordatorio?.toString().substring(0,10) ?? '-'}'),
                                            if ((e.fuente ?? '').isNotEmpty) Text('Fuente: ${e.fuente}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Cerrar')),
                                        ],
                                      );
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error cargando eventos: $e'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Función: _itemFiltro - elemento de menú para filtrar eventos.
  PopupMenuItem<EventFilter> _itemFiltro(
      EventFilter value, String label, IconData icon, EventFilter current,
      ) {
    return PopupMenuItem<EventFilter>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: current == value ? Colors.amber[800] : null),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          if (current == value) const Icon(Icons.check, size: 18),
        ],
      ),
    );
  }

  // Función: _nuevoEventoDialog - diálogo para crear evento privado.
  Future<bool?> _nuevoEventoDialog(BuildContext context) async {
    final repo = ref.read(misEventosRepositoryProvider);
    final titulo = TextEditingController();
    final desc = TextEditingController();
    DateTime fecha = _selected;
    TimeOfDay hora = const TimeOfDay(hour: 9, minute: 0);
    bool allDay = false;

    DateTime compose(DateTime d, TimeOfDay t) => DateTime(d.year, d.month, d.day, t.hour, t.minute);

    return showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('Nuevo evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(decoration: const InputDecoration(labelText: 'Título'), controller: titulo),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                  controller: desc,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text('${fecha.day}/${fecha.month}/${fecha.year}'),
                      onPressed: () async {
                        final p = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: DateTime(2030, 12, 31),
                          locale: const Locale('es', 'ES'),
                        );
                        if (p != null) setLocal(() => fecha = p);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(allDay ? 'Todo el día' : hora.format(context)),
                      onPressed: allDay
                          ? null
                          : () async {
                        final p = await showTimePicker(context: context, initialTime: hora);
                        if (p != null) setLocal(() => hora = p);
                      },
                    ),
                  ),
                ]),
                SwitchListTile(
                  value: allDay,
                  title: const Text('Todo el día'),
                  onChanged: (v) => setLocal(() => allDay = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              FilledButton(
                onPressed: () async {
                  if (titulo.text.trim().isEmpty) return;
                  final start = allDay ? DateTime(fecha.year, fecha.month, fecha.day) : compose(fecha, hora);
                  try {
                    await repo.crear(
                      titulo: titulo.text.trim(),
                      descripcion: desc.text.trim().isEmpty ? null : desc.text.trim(),
                      inicio: start,
                      fin: null,
                      allDay: allDay,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  } on StateError {
                    if (context.mounted) {
                      Navigator.pop(context, false);
                      showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text('No disponible'),
                          content: Text('Para guardar eventos personales, habilita Anonymous sign-in en Supabase.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget: _LegendItem - elemento de la leyenda del calendario.
class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _LegendItem({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: const [
        _LegendItem(icon: Icons.assignment_outlined, color: Colors.amber, label: 'Obligaciones'),
        _LegendItem(icon: Icons.event, color: Colors.blue, label: 'Mis eventos'),
        _LegendItem(icon: Icons.flag, color: Colors.red, label: 'Feriados'),
      ],
    );
  }
}
