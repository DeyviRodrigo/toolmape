import '../../domain/entities/metal_entity.dart';
import '../dtos/metal_dto.dart';

class MetalMapper {
  static MetalEntity fromDto(MetalDto dto) => MetalEntity(
        code: dto.code,
        description: dto.description,
        defaultUnitCode: dto.defaultUnitCode,
        chemicalSymbol: dto.chemicalSymbol,
      );

  static MetalDto toDto(MetalEntity entity) => MetalDto(
        code: entity.code,
        description: entity.description,
        defaultUnitCode: entity.defaultUnitCode,
        chemicalSymbol: entity.chemicalSymbol,
      );
}
