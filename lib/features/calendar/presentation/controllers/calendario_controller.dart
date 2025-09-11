import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/calendar/domain/entities/evento_entity.dart';
import 'package:toolmape/features/calendar/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/features/calendar/domain/repositories/calendario_repository.dart';
import 'package:toolmape/features/calendar/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/features/calendar/domain/value_objects/date_range.dart';
import 'package:toolmape/app/init_dependencies.dart';
import 'package:toolmape/presentation/shared/event_filter.dart';
import 'package:toolmape/presentation/shared/meses.dart';

class CalendarioState {
  final DateTime focused;
  final DateTime selected;
  final EventFilter filtro;

  const CalendarioState({
    required this.focused,
    required this.selected,
    required this.filtro,
  });

  CalendarioState copyWith({
    DateTime? focused,
    DateTime? selected,
    EventFilter? filtro,
  }) => CalendarioState(
        focused: focused ?? this.focused,
        selected: selected ?? this.selected,
        filtro: filtro ?? this.filtro,
      );
}

class CalendarioViewModel extends StateNotifier<CalendarioState> {
  CalendarioViewModel(this._calRepo, this._misRepo)
      : super(CalendarioState(
          focused: DateTime.now(),
          selected: DateTime.now(),
          filtro: EventFilter.all,
        ));

  final CalendarioRepository _calRepo;
  final MisEventosRepository _misRepo;

  // Mutators
  void setFocused(DateTime f) => state = state.copyWith(focused: f);
  void setSelected(DateTime s) => state = state.copyWith(selected: s);
  void setFiltro(EventFilter f) => state = state.copyWith(filtro: f);

  // Derived getters
  DateTime get mesClave => DateTime(state.focused.year, state.focused.month, 1);
  DateTimeRange get mesRango {
    final first = DateTime(state.focused.year, state.focused.month, 1);
    final last = DateTime(state.focused.year, state.focused.month + 1, 0);
    return DateTimeRange(
      start: first,
      end: DateTime(last.year, last.month, last.day, 23, 59, 59),
    );
  }

  Future<List<EventoEntity>> eventosDelMes(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    return _calRepo.eventosEnRango(start: start, end: end);
  }

  Future<List<MiEventoEntity>> misEventos(DateTimeRange range) {
    return _misRepo.eventosEnRango(DateRange(start: range.start, end: range.end));
  }

  DateTime? fechaVenc(EventoEntity e) => e.fin ?? e.inicio ?? e.recordatorio;
  bool esFeriado(EventoEntity e) => (e.categoria ?? '').toLowerCase() == 'fechas festivas';

  IconData iconoPara(EventoEntity e) {
    final cat = (e.categoria ?? '').toLowerCase();
    final t = e.titulo.toLowerCase();
    if (cat == 'feriado') return Icons.flag;
    if (t.contains('afp')) return Icons.payments_outlined;
    if (t.contains('agua')) return Icons.water_drop_outlined;
    if (t.contains('sucamec') || t.contains('explosiv')) return Icons.bolt_outlined;
    if (t.contains('estamin')) return Icons.insert_chart_outlined;
    if (t.contains('iqbf') || t.contains('insumos')) return Icons.science_outlined;
    if (t.contains('sunat') || t.contains('tributarias')) return Icons.assignment_outlined;
    return Icons.event_note_outlined;
  }

  String mesNombrePublic(int m) => mesNombre(m);
}

final calendarioViewModelProvider =
    StateNotifierProvider<CalendarioViewModel, CalendarioState>((ref) {
  final calRepo = ref.read(calendarioRepositoryProvider);
  final misRepo = ref.read(misEventosRepositoryProvider);
  return CalendarioViewModel(calRepo, misRepo);
});
