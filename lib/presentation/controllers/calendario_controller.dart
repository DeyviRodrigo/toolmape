import 'package:flutter/material.dart' show DateTimeRange;

import '../../domain/entities/evento_entity.dart';
import '../../domain/entities/mi_evento_entity.dart';
import '../../domain/usecases/crear_evento_usecase.dart';
import '../../domain/usecases/get_eventos_mes_usecase.dart';
import '../../domain/usecases/get_mis_eventos_usecase.dart';
import '../../domain/usecases/schedule_notifications_usecase.dart';

/// Controller that delegates calendar operations to domain use cases.
class CalendarioController {
  CalendarioController({
    required GetEventosMes getEventosMes,
    required GetMisEventos getMisEventos,
    required CrearEvento crearEvento,
    required ScheduleNotifications scheduleNotifications,
  })  : _getEventosMes = getEventosMes,
        _getMisEventos = getMisEventos,
        _crearEvento = crearEvento,
        _scheduleNotifications = scheduleNotifications;

  final GetEventosMes _getEventosMes;
  final GetMisEventos _getMisEventos;
  final CrearEvento _crearEvento;
  final ScheduleNotifications _scheduleNotifications;

  Future<List<EventoEntity>> eventosDelMes(DateTime month) {
    return _getEventosMes(month);
  }

  Future<List<MiEventoEntity>> misEventos(DateTimeRange range) {
    return _getMisEventos(range);
  }

  Future<void> crearEvento({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) {
    return _crearEvento(
      titulo: titulo,
      descripcion: descripcion,
      inicio: inicio,
      fin: fin,
      allDay: allDay,
    );
  }

  Future<void> programarNotificaciones({
    required List<EventoEntity> eventos,
    required int? rucLastDigit,
    required String? regimen,
  }) {
    return _scheduleNotifications(
      eventos: eventos,
      rucLastDigit: rucLastDigit,
      regimen: regimen,
    );
  }
}
