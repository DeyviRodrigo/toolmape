import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource contract for calendar events.
abstract class CalendarioDatasource {
  Future<List<Map<String, dynamic>>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  });
}

/// Supabase implementation of [CalendarioDatasource].
class CalendarioSupabaseDatasource implements CalendarioDatasource {
  CalendarioSupabaseDatasource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    final sIso = DateTime(start.year, start.month, start.day).toIso8601String();
    final eIso =
        DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();

    final res = await _client
        .from('calendario_eventos')
        .select('*')
        .or(
          'and(inicio.gte.$sIso,inicio.lte.$eIso),'
          'and(fin.gte.$sIso,fin.lte.$eIso),'
          'and(recordatorio.gte.$sIso,recordatorio.lte.$eIso)',
        )
        .order('fin', ascending: true, nullsFirst: true)
        .order('recordatorio', ascending: true, nullsFirst: true)
        .order('inicio', ascending: true, nullsFirst: true);

    return (res as List).cast<Map<String, dynamic>>();
  }
}
