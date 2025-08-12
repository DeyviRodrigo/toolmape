import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mis_eventos_repo.dart';
import 'mi_evento.dart';
import 'calendario_controller.dart' show supabaseClientProvider;

/// Repo inyectado con el SupabaseClient global
final misEventosRepoProvider = Provider<MisEventosRepo>((ref) {
  final supa = ref.read(supabaseClientProvider);
  return MisEventosRepo(supa);
});

/// Eventos del usuario en un rango de fechas (lo usamos con el mes visible)
final misEventosRangoProvider =
FutureProvider.family<List<MiEvento>, DateTimeRange>((ref, rango) async {
  return ref
      .read(misEventosRepoProvider)
      .eventosEnRango(rango.start, rango.end);
});
