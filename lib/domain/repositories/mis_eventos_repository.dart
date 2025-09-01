import '../entities/mi_evento_entity.dart';
import '../value_objects/date_range.dart';

/// Repository contract for personal user events.
abstract class MisEventosRepository {
  /// Whether anonymous authentication is disabled in Supabase.
  bool get anonDisabled;

  /// Personal events for the current user within [range].
  Future<List<MiEventoEntity>> eventosEnRango(DateRange range);

  /// Creates a new personal event for the current user.
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  });

  /// Deletes a personal event by its [id].
  Future<void> borrar(String id);
}
