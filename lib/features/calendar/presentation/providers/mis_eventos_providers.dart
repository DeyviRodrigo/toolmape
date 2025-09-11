import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/calendar/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/features/calendar/domain/value_objects/date_range.dart';
import 'package:toolmape/app/init_dependencies.dart';

/// Provider: misEventosRangoProvider - eventos personales del usuario en un rango.
final misEventosRangoProvider =
    FutureProvider.family<List<MiEventoEntity>, DateRange>((ref, rango) async {
  final repo = ref.read(misEventosRepositoryProvider);
  return repo.eventosEnRango(rango);
});
