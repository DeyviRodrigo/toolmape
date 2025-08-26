import '../../domain/repositories/mis_eventos_repository.dart';
import '../../features/calendario/mi_evento.dart';
import '../datasources/mis_eventos_supabase_ds.dart';

/// Repository implementation for personal events.
class MisEventosRepositoryImpl implements MisEventosRepository {
  MisEventosRepositoryImpl(this._ds);
  final MisEventosDatasource _ds;

  @override
  bool get anonDisabled => _ds.anonDisabled;

  @override
  Future<List<MiEvento>> eventosEnRango(DateTime start, DateTime end) async {
    final data = await _ds.eventosEnRango(start, end);
    return data.map((e) => MiEvento.fromMap(e)).toList();
  }

  @override
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) {
    return _ds.crear(
      titulo: titulo,
      descripcion: descripcion,
      inicio: inicio,
      fin: fin,
      allDay: allDay,
    );
  }

  @override
  Future<void> borrar(String id) => _ds.borrar(id);
}
