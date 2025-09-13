import '../../domain/entities/unit_entity.dart';
import '../dtos/unit_dto.dart';

class UnitMapper {
  static UnitEntity fromDto(UnitDto dto) => UnitEntity(
        code: dto.code,
        name: dto.name,
        ratioToGram: dto.ratioToGram,
      );

  static UnitDto toDto(UnitEntity entity) => UnitDto(
        code: entity.code,
        name: entity.name,
        ratioToGram: entity.ratioToGram,
      );
}
