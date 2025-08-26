import '../../domain/repositories/calendario_repository.dart';
import '../../features/calendario/eventos_calendario.dart';
import '../datasources/calendario_supabase_ds.dart';

/// Repository implementation that delegates to a [CalendarioDatasource].
class CalendarioRepositoryImpl implements CalendarioRepository {
  CalendarioRepositoryImpl(this._ds);
  final CalendarioDatasource _ds;

  @override
  Future<List<EventoCalendar>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    final data = await _ds.eventosEnRango(start: start, end: end);
    return data.map((e) => EventoCalendar.fromMap(e)).toList();
  }
}
