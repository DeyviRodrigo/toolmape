import '../../domain/entities/evento_entity.dart';
import '../../domain/repositories/calendario_repository.dart';
import '../datasources/calendario_supabase_ds.dart';
import '../dto/evento_dto.dart';
import '../mappers/evento_mapper.dart';

/// Repository implementation that delegates to a [CalendarioDatasource].
class CalendarioRepositoryImpl implements CalendarioRepository {
  CalendarioRepositoryImpl(this._ds);
  final CalendarioDatasource _ds;

  @override
  Future<List<EventoEntity>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    final data = await _ds.eventosEnRango(start: start, end: end);
    return data
        .map((e) => EventoMapper.fromDto(EventoDto.fromJson(e)))
        .toList();
  }
}
