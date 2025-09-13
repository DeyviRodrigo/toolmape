import '../../domain/entities/currency_entity.dart';
import '../dtos/currency_dto.dart';

class CurrencyMapper {
  static CurrencyEntity fromDto(CurrencyDto dto) => CurrencyEntity(
        code: dto.code,
        name: dto.name,
        symbol: dto.symbol,
        decimals: dto.decimals,
      );

  static CurrencyDto toDto(CurrencyEntity entity) => CurrencyDto(
        code: entity.code,
        name: entity.name,
        symbol: entity.symbol,
        decimals: entity.decimals,
      );
}
