import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'eventos_calendario.dart';

/// Enum: EventFilter - filtros disponibles para eventos.
enum EventFilter { all, general, personal }

/// Clase: CalendarioState - estado para la pantalla de calendario.
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

/// Notifier: CalendarioViewModel - maneja estado y utilitarios del calendario.
class CalendarioViewModel extends Notifier<CalendarioState> {
  @override
  CalendarioState build() {
    final now = DateTime.now();
    return CalendarioState(focused: now, selected: now, filtro: EventFilter.all);
  }

  // Mutadores
  void setFocused(DateTime f) => state = state.copyWith(focused: f);
  void setSelected(DateTime s) => state = state.copyWith(selected: s);
  void setFiltro(EventFilter f) => state = state.copyWith(filtro: f);

  // Getters derivados
  DateTime get mesClave => DateTime(state.focused.year, state.focused.month, 1);
  DateTimeRange get mesRango {
    final first = DateTime(state.focused.year, state.focused.month, 1);
    final last = DateTime(state.focused.year, state.focused.month + 1, 0);
    return DateTimeRange(
      start: first,
      end: DateTime(last.year, last.month, last.day, 23, 59, 59),
    );
  }

  /// Fecha de vencimiento para pintar (prioridad: fin > inicio > recordatorio)
  DateTime? fechaVenc(EventoCalendar e) => e.fin ?? e.inicio ?? e.recordatorio;

  /// Determina si el evento es feriado.
  bool esFeriado(EventoCalendar e) => (e.categoria ?? '').toLowerCase() == 'fechas festivas';

  /// Icono por categoría/título del evento.
  IconData iconoPara(EventoCalendar e) {
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

  /// Nombre del mes.
  String mesNombre(int m) {
    const meses = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[m];
  }
}

/// Provider: calendarioViewModelProvider - expone CalendarioViewModel.
final calendarioViewModelProvider =
    NotifierProvider<CalendarioViewModel, CalendarioState>(CalendarioViewModel.new);

