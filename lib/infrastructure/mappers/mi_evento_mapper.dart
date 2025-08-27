import '../../domain/entities/mi_evento_entity.dart';
import '../dto/mi_evento_dto.dart';

class MiEventoMapper {
  static MiEventoEntity fromDto(MiEventoDto dto) => MiEventoEntity(
        id: dto.id,
        userId: dto.userId,
        titulo: dto.titulo,
        descripcion: dto.descripcion,
        inicio: dto.inicio,
        fin: dto.fin,
        allDay: dto.allDay,
      );

  static MiEventoDto toDto(MiEventoEntity entity) => MiEventoDto(
        id: entity.id,
        userId: entity.userId,
        titulo: entity.titulo,
        descripcion: entity.descripcion,
        inicio: entity.inicio,
        fin: entity.fin,
        allDay: entity.allDay,
      );
}
