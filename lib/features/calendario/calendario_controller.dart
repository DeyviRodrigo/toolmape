import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/notifications/calendario_notifications.dart';
import 'calendario_repo.dart';
import 'eventos_calendario.dart';

// --- Providers base ---
/// Provider: supabaseClientProvider - cliente de Supabase.
final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Provider: calendarioRepoProvider - repositorio de calendario.
final calendarioRepoProvider = Provider<CalendarioRepo>((ref) {
  return CalendarioRepo(ref.read(supabaseClientProvider));
});

/// Provider: eventosMesProvider - eventos del MES visible (usa rango 1..último día).
final eventosMesProvider =
    FutureProvider.family<List<EventoCalendar>, DateTime>((ref, focused) async {
  final repo = ref.read(calendarioRepoProvider);
  final start = DateTime(focused.year, focused.month, 1);
  final end   = DateTime(focused.year, focused.month + 1, 0);
  return repo.eventosEnRango(start: start, end: end);
});

// --- Notificaciones locales (recordatorio + inicio + fin a las 09:00) ---
/// Función: programarNotificacionesPara - programa notificaciones para eventos.
Future<void> programarNotificacionesPara({
  required List<EventoCalendar> eventos,
  required int? rucLastDigit,
  required String? regimen,
}) async {
  if (kIsWeb) return; // en web no hay plugin

  await CalendarioNotifications.cancelAll();
  int id = 3000;
  DateTime at0900(DateTime d) => DateTime(d.year, d.month, d.day, 9);

  for (final e in eventos) {
    if (!e.aplicaA(rucDigit: rucLastDigit, regimen: regimen)) continue;

    if (e.recordatorio != null && e.recordatorio!.isAfter(DateTime.now())) {
      await CalendarioNotifications.scheduleOnce(
        id: id++,
        when: at0900(e.recordatorio!),
        title: e.titulo,
        body: 'Recordatorio (${e.categoria ?? 'Obligación'})',
      );
    }
    if (e.inicio != null && e.inicio!.isAfter(DateTime.now())) {
      await CalendarioNotifications.scheduleOnce(
        id: id++,
        when: at0900(e.inicio!),
        title: e.titulo,
        body: 'Inicio de plazo (${e.categoria ?? 'Obligación'})',
      );
    }
    if (e.fin != null && e.fin!.isAfter(DateTime.now())) {
      await CalendarioNotifications.scheduleOnce(
        id: id++,
        when: at0900(e.fin!),
        title: e.titulo,
        body: 'Fin de plazo (${e.categoria ?? 'Obligación'})',
      );
    }
  }
}
