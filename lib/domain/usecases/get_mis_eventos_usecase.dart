import 'package:flutter/material.dart' show DateTimeRange;

import '../../features/calendario/mi_evento.dart';
import '../../features/calendario/mis_eventos_repo.dart';

/// Use case to obtain personal events for a given range.
class GetMisEventos {
  GetMisEventos(this._repo);
  final MisEventosRepo _repo;

  Future<List<MiEvento>> call(DateTimeRange range) {
    return _repo.eventosEnRango(range.start, range.end);
  }
}
