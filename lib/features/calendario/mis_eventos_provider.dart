import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'mi_evento.dart';
import 'mis_eventos_repo.dart';

/// Repo de eventos personales
final misEventosRepoProvider = Provider<MisEventosRepo>((ref) {
  return MisEventosRepo(Supabase.instance.client);
});

/// Eventos personales del usuario en un rango (p. ej. el mes visible)
final misEventosRangoProvider =
FutureProvider.family<List<MiEvento>, DateTimeRange>((ref, rango) async {
  return ref
      .read(misEventosRepoProvider)
      .eventosEnRango(rango.start, rango.end);
});
