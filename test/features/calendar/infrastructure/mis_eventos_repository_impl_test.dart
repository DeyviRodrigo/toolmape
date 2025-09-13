import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calendar/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/features/calendar/domain/value_objects/date_range.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/mis_eventos_supabase_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/mis_eventos_repository_impl.dart';

class _FakeMisEventosDs implements MisEventosDatasource {
  DateTime? start;
  DateTime? end;
  String? created;
  String? deleted;
  bool anon = false;

  @override
  bool get anonDisabled => anon;

  @override
  Future<List<Map<String, dynamic>>> eventosEnRango(DateTime start, DateTime end) async {
    this.start = start;
    this.end = end;
    return [
      {
        'id': '1',
        'user_id': 'u',
        'titulo': 'p',
        'descripcion': null,
        'inicio': start.toIso8601String(),
        'fin': null,
        'all_day': false,
      }
    ];
  }

  @override
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {
    created = titulo;
  }

  @override
  Future<void> borrar(String id) async {
    deleted = id;
  }
}

void main() {
  test('MisEventosRepositoryImpl delegates to datasource', () async {
    final ds = _FakeMisEventosDs();
    final repo = MisEventosRepositoryImpl(ds);
    final s = DateTime(2024, 1, 1);
    final e = DateTime(2024, 1, 2);
    final res = await repo.eventosEnRango(DateRange(start: s, end: e));
    expect(ds.start, s);
    expect(ds.end, e);
    expect(res, isA<List<MiEventoEntity>>());
    await repo.crear(titulo: 'x', inicio: s, fin: e);
    expect(ds.created, 'x');
    await repo.borrar('1');
    expect(ds.deleted, '1');
    expect(repo.anonDisabled, isFalse);
  });
}
