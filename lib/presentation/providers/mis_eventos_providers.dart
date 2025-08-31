import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/mi_evento_entity.dart';
import '../../domain/repositories/mis_eventos_repository.dart';
import '../../infrastructure/repositories/mis_eventos_repository_impl.dart';
import '../../infrastructure/datasources/mis_eventos_supabase_ds.dart';

/// Provider: misEventosRepoProvider - repositorio de eventos personales.
final misEventosRepoProvider = Provider<MisEventosRepository>((ref) {
  final ds = MisEventosSupabaseDatasource(Supabase.instance.client);
  return MisEventosRepositoryImpl(ds);
});

/// Provider: misEventosRangoProvider - eventos personales del usuario en un rango.
final misEventosRangoProvider =
    FutureProvider.family<List<MiEventoEntity>, DateTimeRange>((ref, rango) async {
  return ref
      .read(misEventosRepoProvider)
      .eventosEnRango(rango.start, rango.end);
});
