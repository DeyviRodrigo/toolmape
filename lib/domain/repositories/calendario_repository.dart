import '../../features/calendario/eventos_calendario.dart';

/// Repository contract for calendar events.
abstract class CalendarioRepository {
  /// Events whose start, end or reminder lies within the given range.
  Future<List<EventoCalendar>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  });
}
