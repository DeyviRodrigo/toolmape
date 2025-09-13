import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calendar/domain/entities/evento_entity.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/calendario_supabase_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/calendario_repository_impl.dart';

class _FakeCalendarioDs implements CalendarioDatasource {
  DateTime? start;
  DateTime? end;
  @override
  Future<List<Map<String, dynamic>>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    this.start = start;
    this.end = end;
    return [
      {
        'id': '1',
        'titulo': 't',
        'descripcion': null,
        'categoria': null,
        'inicio': start.toIso8601String(),
        'fin': end.toIso8601String(),
        'recordatorio': null,
        'alcance': <String, dynamic>{},
        'fuente': null,
      }
    ];
  }
}

void main() {
  test('CalendarioRepositoryImpl delegates to datasource', () async {
    final ds = _FakeCalendarioDs();
    final repo = CalendarioRepositoryImpl(ds);
    final s = DateTime(2024, 1, 1);
    final e = DateTime(2024, 1, 2);
    final res = await repo.eventosEnRango(start: s, end: e);
    expect(ds.start, s);
    expect(ds.end, e);
    expect(res, isA<List<EventoEntity>>());
    expect(res.length, 1);
  });
}
