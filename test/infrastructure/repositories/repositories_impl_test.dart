import 'package:flutter_test/flutter_test.dart';

import 'package:toolmape/features/calendar/domain/entities/evento_entity.dart';
import 'package:toolmape/features/calendar/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/features/calendar/domain/value_objects/date_range.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/calendario_supabase_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/mis_eventos_supabase_ds.dart';
import 'package:toolmape/features/general/infrastructure/datasources/preferencias_local_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/calendario_repository_impl.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/mis_eventos_repository_impl.dart';
import 'package:toolmape/features/general/infrastructure/repositories/preferencias_repository_impl.dart';

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

class _FakeMisEventosDs implements MisEventosDatasource {
  DateTime? start;
  DateTime? end;
  String? created;
  String? deleted;
  bool anon = false;

  @override
  bool get anonDisabled => anon;

  @override
  Future<List<Map<String, dynamic>>> eventosEnRango(
      DateTime start, DateTime end) async {
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

class _FakePrefsDs extends PreferenciasLocalDatasource {
  CalculatorPrefs? saved;
  bool loadCalled = false;
  @override
  Future<CalculatorPrefs> load() async {
    loadCalled = true;
    return const CalculatorPrefs(
      precioOro: '1',
      tipoCambio: '2',
      descuento: '3',
      ley: '4',
      cantidad: '5',
    );
  }

  @override
  Future<void> save(CalculatorPrefs data) async {
    saved = data;
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

  test('PreferenciasRepositoryImpl delegates to datasource', () async {
    final ds = _FakePrefsDs();
    final repo = PreferenciasRepositoryImpl(ds);
    await repo.save(const CalculatorPrefs(
      precioOro: '10',
      tipoCambio: '20',
      descuento: '5',
      ley: '90',
      cantidad: '2',
    ));
    expect(ds.saved?.precioOro, '10');
    final loaded = await repo.load();
    expect(ds.loadCalled, isTrue);
    expect(loaded.tipoCambio, '2');
  });
}
