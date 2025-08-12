import 'package:supabase_flutter/supabase_flutter.dart';
import 'eventos_calendario.dart';

class CalendarioRepo {
  CalendarioRepo(this._client);
  final SupabaseClient _client;

  Future<List<int>> aniosDisponibles() async {
    final res = await _client
        .from('calendario_eventos')
        .select('anio')
        .order('anio', ascending: true);
    final all = (res as List).map((e) => e['anio'] as int).toSet().toList()..sort();
    return all;
  }

  Future<List<EventoCalendar>> eventosPorAnio({required int anio}) async {
    final res = await _client
        .from('calendario_eventos')
        .select('*')
        .eq('anio', anio)
        .order('inicio', ascending: true, nullsFirst: true)
        .order('recordatorio', ascending: true, nullsFirst: true)
        .order('fin', ascending: true, nullsFirst: true);
    return (res as List).map((e) => EventoCalendar.fromMap(e)).toList();
  }
}