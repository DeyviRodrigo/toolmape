import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calendar/domain/entities/evento_entity.dart';
import 'package:toolmape/features/calendar/domain/value_objects/event_scope.dart';
import 'package:toolmape/features/calendar/domain/usecases/schedule_notifications_usecase.dart';

void main() {
  test('schedules notifications for matching events', () async {
    int cancelCount = 0;
    final scheduled = <Map<String, dynamic>>[];
    final usecase = ScheduleNotifications(
      cancelAll: () async => cancelCount++,
      scheduleOnce: ({required int id, required DateTime when, required String title, required String body}) async {
        scheduled.add({'id': id, 'when': when, 'title': title, 'body': body});
      },
    );

    final now = DateTime.now();
    final event1 = EventoEntity(
      id: '1',
      titulo: 'e1',
      descripcion: null,
      categoria: 'Cat',
      inicio: now.add(const Duration(days: 1)),
      fin: now.add(const Duration(days: 2)),
      recordatorio: now.add(const Duration(days: 3)),
      alcance: const EventScope(),
      fuente: null,
    );

    final event2 = EventoEntity(
      id: '2',
      titulo: 'e2',
      descripcion: null,
      categoria: 'Cat',
      inicio: now.add(const Duration(days: 1)),
      fin: null,
      recordatorio: null,
      alcance: const EventScope(rucDigits: [9]),
      fuente: null,
    );

    await usecase(eventos: [event1, event2], rucLastDigit: 1, regimen: null, isWeb: false);

    expect(cancelCount, 1);
    expect(scheduled.length, 3);
    expect(scheduled.first['title'], 'e1');
  });
}
