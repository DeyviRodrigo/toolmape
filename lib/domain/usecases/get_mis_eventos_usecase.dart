import 'package:flutter/material.dart' show DateTimeRange;

import '../../features/calendario/mi_evento.dart';
import '../repositories/mis_eventos_repository.dart';

/// Use case to obtain personal events for a given range.
class GetMisEventos {
  GetMisEventos(this._repo);
  final MisEventosRepository _repo;

  Future<List<MiEvento>> call(DateTimeRange range) {
    return _repo.eventosEnRango(range.start, range.end);
  }
}
