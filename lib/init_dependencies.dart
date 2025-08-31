import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'domain/repositories/preferencias_repository.dart';
import 'domain/repositories/calendario_repository.dart';
import 'domain/repositories/mis_eventos_repository.dart';
import 'infrastructure/datasources/preferencias_local_ds.dart';
import 'infrastructure/datasources/calendario_supabase_ds.dart';
import 'infrastructure/datasources/mis_eventos_supabase_ds.dart';
import 'infrastructure/repositories/preferencias_repository_impl.dart';
import 'infrastructure/repositories/calendario_repository_impl.dart';
import 'infrastructure/repositories/mis_eventos_repository_impl.dart';

final preferenciasRepositoryProvider = Provider<PreferenciasRepository>((ref) {
  final ds = PreferenciasLocalDatasource();
  return PreferenciasRepositoryImpl(ds);
});

final calendarioRepositoryProvider = Provider<CalendarioRepository>((ref) {
  final ds = CalendarioSupabaseDatasource(Supabase.instance.client);
  return CalendarioRepositoryImpl(ds);
});

final misEventosRepositoryProvider = Provider<MisEventosRepository>((ref) {
  final ds = MisEventosSupabaseDatasource(Supabase.instance.client);
  return MisEventosRepositoryImpl(ds);
});

Future<void> initDependencies() async {
  // Additional initialization if required in the future.
}
