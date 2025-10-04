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

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

// Datasources
final preferenciasLocalDsProvider =
    Provider<PreferenciasLocalDatasource>(
  (ref) => PreferenciasLocalDatasource(),
);

final calendarioSupabaseDsProvider = Provider<CalendarioSupabaseDatasource>(
  (ref) => CalendarioSupabaseDatasource(ref.read(supabaseClientProvider)),
);

final misEventosSupabaseDsProvider = Provider<MisEventosSupabaseDatasource>(
  (ref) => MisEventosSupabaseDatasource(ref.read(supabaseClientProvider)),
);

final diccionarioSupabaseDsProvider = Provider<DiccionarioSupabaseDatasource>(
  (ref) => DiccionarioSupabaseDatasource(ref.read(supabaseClientProvider)),
);

// Repos (MISMO nombre público que hoy)
final preferenciasRepositoryProvider = Provider<PreferenciasRepository>(
  (ref) => PreferenciasRepositoryImpl(ref.read(preferenciasLocalDsProvider)),
);

final calendarioRepositoryProvider = Provider<CalendarioRepository>(
  (ref) => CalendarioRepositoryImpl(ref.read(calendarioSupabaseDsProvider)),
);

final misEventosRepositoryProvider = Provider<MisEventosRepository>(
  (ref) => MisEventosRepositoryImpl(ref.read(misEventosSupabaseDsProvider)),
);

final diccionarioRepositoryProvider = Provider<DiccionarioRepository>(
  (ref) => DiccionarioRepositoryImpl(ref.read(diccionarioSupabaseDsProvider)),
);

Future<void> initDependencies() async {
  // Additional initialization if required in the future.
}
