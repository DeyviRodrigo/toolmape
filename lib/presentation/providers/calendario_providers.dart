import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/evento_entity.dart';
import '../../init_dependencies.dart';

/// Provider: eventosMesProvider - eventos del MES visible (usa rango 1..último día).
final eventosMesProvider =
    FutureProvider.family<List<EventoEntity>, DateTime>((ref, focused) async {
  final repo = ref.read(calendarioRepositoryProvider);
  final start = DateTime(focused.year, focused.month, 1);
  final end = DateTime(focused.year, focused.month + 1, 0);
  return repo.eventosEnRango(start: start, end: end);
});
