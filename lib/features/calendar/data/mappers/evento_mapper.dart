import '../../domain/entities/evento_entity.dart';
import '../dtos/evento_dto.dart';

class EventoMapper {
  static EventoEntity fromDto(EventoDto dto) => EventoEntity(
        id: dto.id,
        titulo: dto.titulo,
        descripcion: dto.descripcion,
        categoria: dto.categoria,
        inicio: dto.inicio,
        fin: dto.fin,
        recordatorio: dto.recordatorio,
        alcance: dto.alcance,
        fuente: dto.fuente,
      );

  static EventoDto toDto(EventoEntity entity) => EventoDto(
        id: entity.id,
        titulo: entity.titulo,
        descripcion: entity.descripcion,
        categoria: entity.categoria,
        inicio: entity.inicio,
        fin: entity.fin,
        recordatorio: entity.recordatorio,
        alcance: entity.alcance,
        fuente: entity.fuente,
      );
}
