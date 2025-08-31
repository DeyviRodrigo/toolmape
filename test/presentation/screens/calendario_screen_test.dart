import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/domain/repositories/calendario_repository.dart';
import 'package:toolmape/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/domain/value_objects/date_range_entity.dart';
import 'package:toolmape/domain/usecases/crear_evento_usecase.dart';
import 'package:toolmape/domain/usecases/get_eventos_mes_usecase.dart';
import 'package:toolmape/domain/usecases/get_mis_eventos_usecase.dart';
import 'package:toolmape/domain/usecases/schedule_notifications_usecase.dart';
import 'package:toolmape/presentation/controllers/calendario_controller.dart';
import 'package:toolmape/presentation/screens/calendario_screen.dart';

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
  Future<List<MiEventoEntity>> eventosEnRango(DateRange range) async =>
      <MiEventoEntity>[];

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

void main() {
  testWidgets('shows event count and button', (tester) async {
    final controller = CalendarioController(
      getEventosMes: GetEventosMes(_FakeCalRepo()),
      getMisEventos: GetMisEventos(_FakeMisRepo()),
      crearEvento: CrearEvento(_FakeMisRepo()),
      scheduleNotifications: ScheduleNotifications(
        cancelAll: () async {},
        scheduleOnce:
            ({
              required int id,
              required DateTime when,
              required String title,
              required String body,
            }) async {},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: CalendarioScreen(controller: controller)),
    );
    await tester.pump(); // resolve future

    expect(find.text('Eventos este mes: 0'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
