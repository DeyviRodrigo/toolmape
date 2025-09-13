import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:toolmape/features/general/domain/repositories/preferencias_repository.dart';
import 'package:toolmape/features/calendar/domain/repositories/calendario_repository.dart';
import 'package:toolmape/features/calendar/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/features/general/domain/repositories/diccionario_repository.dart';
import 'package:toolmape/features/general/infrastructure/datasources/preferencias_local_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/calendario_supabase_ds.dart';
import 'package:toolmape/features/calendar/infrastructure/datasources/mis_eventos_supabase_ds.dart';
import 'package:toolmape/features/general/infrastructure/datasources/diccionario_supabase_ds.dart';
import 'package:toolmape/features/general/infrastructure/repositories/preferencias_repository_impl.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/calendario_repository_impl.dart';
import 'package:toolmape/features/calendar/infrastructure/repositories/mis_eventos_repository_impl.dart';
import 'package:toolmape/features/general/infrastructure/repositories/diccionario_repository_impl.dart';

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

final diccionarioRepositoryProvider = Provider<DiccionarioRepository>((ref) {
  final ds = DiccionarioSupabaseDatasource(Supabase.instance.client);
  return DiccionarioRepositoryImpl(ds);
});

Future<void> initDependencies() async {
  // Additional initialization if required in the future.
}
