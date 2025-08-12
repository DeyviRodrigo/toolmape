import 'package:supabase_flutter/supabase_flutter.dart';
import 'eventos_calendario.dart';

class CalendarioRepo {
  CalendarioRepo(this._client);
  final SupabaseClient _client;

  /// Devuelve todos los eventos cuyo `inicio` **o** `fin` **o** `recordatorio`
  /// cae dentro del [start, end] (inclusive).
  Future<List<EventoCalendar>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    // Normalizamos a ISO (fin de día para 'end' por si usas timestamp)
    final sIso = DateTime(start.year, start.month, start.day).toIso8601String();
    final eIso = DateTime(end.year, end.month, end.day, 23, 59, 59).toIso8601String();

    final res = await _client
        .from('calendario_eventos')
        .select('*')
    // (inicio BETWEEN sIso AND eIso) OR (fin BETWEEN sIso AND eIso) OR (recordatorio BETWEEN sIso AND eIso)
        .or(
      'and(inicio.gte.$sIso,inicio.lte.$eIso),'
          'and(fin.gte.$sIso,fin.lte.$eIso),'
          'and(recordatorio.gte.$sIso,recordatorio.lte.$eIso)',
    )
    // Ordena por fecha de vencimiento (fin), luego recordatorio, luego inicio.
        .order('fin', ascending: true, nullsFirst: true)
        .order('recordatorio', ascending: true, nullsFirst: true)
        .order('inicio', ascending: true, nullsFirst: true);

    return (res as List).map((e) => EventoCalendar.fromMap(e as Map<String, dynamic>)).toList();
  }
}
