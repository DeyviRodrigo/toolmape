import '../entities/mi_evento_entity.dart';
import '../repositories/mis_eventos_repository.dart';
import '../value_objects/date_range_entity.dart';

/// Use case to obtain personal events for a given range.
class GetMisEventos {
  GetMisEventos(this._repo);
  final MisEventosRepository _repo;

  Future<List<MiEventoEntity>> call(DateRange range) {
    return _repo.eventosEnRango(range);
  }
}
