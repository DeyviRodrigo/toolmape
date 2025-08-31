import '../../domain/entities/mi_evento_entity.dart';
import '../../domain/repositories/mis_eventos_repository.dart';
import '../../domain/value_objects/date_range_entity.dart';
import '../datasources/mis_eventos_supabase_ds.dart';
import '../dto/mi_evento_dto.dart';
import '../mappers/mi_evento_mapper.dart';

/// Repository implementation for personal events.
class MisEventosRepositoryImpl implements MisEventosRepository {
  MisEventosRepositoryImpl(this._ds);
  final MisEventosDatasource _ds;

  @override
  bool get anonDisabled => _ds.anonDisabled;

  @override
  Future<List<MiEventoEntity>> eventosEnRango(DateRange range) async {
    final data = await _ds.eventosEnRango(range.start, range.end);
    return data
        .map((e) => MiEventoMapper.fromDto(MiEventoDto.fromJson(e)))
        .toList();
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
