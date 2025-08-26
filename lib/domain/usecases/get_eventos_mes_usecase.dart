import '../repositories/calendario_repository.dart';
import '../../features/calendario/eventos_calendario.dart';

/// Use case to obtain calendar events for a given month.
class GetEventosMes {
  GetEventosMes(this._repo);
  final CalendarioRepository _repo;

  Future<List<EventoCalendar>> call(DateTime focused) {
    final start = DateTime(focused.year, focused.month, 1);
    final end = DateTime(focused.year, focused.month + 1, 0);
    return _repo.eventosEnRango(start: start, end: end);
  }
}
