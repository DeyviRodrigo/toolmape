import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/notifications/calendario_notifications.dart';
import 'calendario_repo.dart';
import 'eventos_calendario.dart';

// Providers globales
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final calendarioRepoProvider = Provider<CalendarioRepo>((ref) {
  return CalendarioRepo(ref.read(supabaseClientProvider));
});

final aniosProvider = FutureProvider<List<int>>((ref) async {
  return ref.read(calendarioRepoProvider).aniosDisponibles();
});

final eventosProvider = FutureProvider.family<List<EventoCalendar>, int>((ref, anio) async {
  return ref.read(calendarioRepoProvider).eventosPorAnio(anio: anio);
});

// Programar notificaciones: recordatorio + inicio + fin (09:00)
Future<void> programarNotificacionesPara({
  required List<EventoCalendar> eventos,
  required int? rucLastDigit,
  required String? regimen,
}) async {
  if (kIsWeb) {
    // En web, el plugin no existe; no programes nada.
    return;
  }
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