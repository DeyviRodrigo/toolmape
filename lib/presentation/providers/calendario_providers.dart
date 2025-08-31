import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/evento_entity.dart';
import '../../domain/repositories/calendario_repository.dart';
import '../../infrastructure/datasources/calendario_supabase_ds.dart';
import '../../infrastructure/repositories/calendario_repository_impl.dart';

/// Provider: supabaseClientProvider - cliente de Supabase.
final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Provider: calendarioRepoProvider - repositorio de calendario.
final calendarioRepoProvider = Provider<CalendarioRepository>((ref) {
  final ds = CalendarioSupabaseDatasource(ref.read(supabaseClientProvider));
  return CalendarioRepositoryImpl(ds);
});

/// Provider: eventosMesProvider - eventos del MES visible (usa rango 1..\u00faltimo d\u00eda).
final eventosMesProvider =
    FutureProvider.family<List<EventoEntity>, DateTime>((ref, focused) async {
  final repo = ref.read(calendarioRepoProvider);
  final start = DateTime(focused.year, focused.month, 1);
  final end = DateTime(focused.year, focused.month + 1, 0);
  return repo.eventosEnRango(start: start, end: end);
});
