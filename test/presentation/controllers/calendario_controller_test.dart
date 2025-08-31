import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/domain/repositories/calendario_repository.dart';
import 'package:toolmape/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/domain/usecases/crear_evento_usecase.dart';
import 'package:toolmape/domain/usecases/get_eventos_mes_usecase.dart';
import 'package:toolmape/domain/usecases/get_mis_eventos_usecase.dart';
import 'package:toolmape/domain/usecases/schedule_notifications_usecase.dart';
import 'package:toolmape/presentation/controllers/calendario_controller.dart';

class _FakeCalRepo implements CalendarioRepository {
  @override
  Future<List<EventoEntity>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async => <EventoEntity>[];
}

class _FakeMisRepo implements MisEventosRepository {
  @override
  bool get anonDisabled => false;

  @override
  Future<List<MiEventoEntity>> eventosEnRango(
    DateTime start,
    DateTime end,
  ) async => <MiEventoEntity>[];

  @override
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {}

  @override
  Future<void> borrar(String id) async {}
}

class _FakeGetEventosMes extends GetEventosMes {
  _FakeGetEventosMes() : super(_FakeCalRepo());
  DateTime? calledWith;
  @override
  Future<List<EventoEntity>> call(DateTime d) async {
    calledWith = d;
    return [];
  }
}

class _FakeGetMisEventos extends GetMisEventos {
  _FakeGetMisEventos() : super(_FakeMisRepo());
  DateTimeRange? calledWith;
  @override
  Future<List<MiEventoEntity>> call(DateTimeRange r) async {
    calledWith = r;
    return [];
  }
}

class _FakeCrearEvento extends CrearEvento {
  _FakeCrearEvento() : super(_FakeMisRepo());
  String? titulo;
  @override
  Future<void> call({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {
    this.titulo = titulo;
  }
}

class _FakeScheduleNotifications extends ScheduleNotifications {
  _FakeScheduleNotifications()
    : super(
        cancelAll: () async {},
        scheduleOnce:
            ({
              required int id,
              required DateTime when,
              required String title,
              required String body,
            }) async {},
      );
  List<EventoEntity>? eventos;
  int? rucDigit;
  String? regimen;
  @override
  Future<void> call({
    required List<EventoEntity> eventos,
    required int? rucLastDigit,
    required String? regimen,
  }) async {
    this.eventos = eventos;
    rucDigit = rucLastDigit;
    this.regimen = regimen;
  }
}

void main() {
  test('controller delegates to use cases', () async {
    final g = _FakeGetEventosMes();
    final m = _FakeGetMisEventos();
    final c = _FakeCrearEvento();
    final s = _FakeScheduleNotifications();

    final controller = CalendarioController(
      getEventosMes: g,
      getMisEventos: m,
      crearEvento: c,
      scheduleNotifications: s,
    );

    final mes = DateTime(2024, 1, 1);
    await controller.eventosDelMes(mes);
    expect(g.calledWith, mes);

    final range = DateTimeRange(
      start: DateTime(2024, 1),
      end: DateTime(2024, 2),
    );
    await controller.misEventos(range);
    expect(m.calledWith, range);

    await controller.crearEvento(titulo: 'test', inicio: DateTime(2024, 1, 1));
    expect(c.titulo, 'test');

    final ev = EventoEntity(
      id: '1',
      titulo: 't',
      descripcion: null,
      categoria: null,
      inicio: null,
      fin: null,
      recordatorio: null,
      alcance: const {},
      fuente: null,
    );
    await controller.programarNotificaciones(
      eventos: [ev],
      rucLastDigit: 1,
      regimen: 'RMT',
    );
    expect(s.eventos, [ev]);
    expect(s.rucDigit, 1);
    expect(s.regimen, 'RMT');
  });
}
