import '../entities/evento_entity.dart';

/// Repository contract for calendar events.
abstract class CalendarioRepository {
  /// Events whose start, end or reminder lies within the given range.
  Future<List<EventoEntity>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  });
}
