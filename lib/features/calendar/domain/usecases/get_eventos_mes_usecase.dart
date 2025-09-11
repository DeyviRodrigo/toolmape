import '../repositories/calendario_repository.dart';
import '../entities/evento_entity.dart';

/// Use case to obtain calendar events for a given month.
class GetEventosMes {
  GetEventosMes(this._repo);
  final CalendarioRepository _repo;

  Future<List<EventoEntity>> call(DateTime focused) {
    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);
    return _repo.eventosEnRango(start: start, end: end);
  }
}
