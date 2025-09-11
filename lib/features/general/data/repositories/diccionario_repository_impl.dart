import '../../domain/entities/unit_entity.dart';
import '../../domain/entities/currency_entity.dart';
import '../../domain/entities/metal_entity.dart';
import '../../domain/repositories/diccionario_repository.dart';
import '../datasources/diccionario_supabase_ds.dart';
import '../dto/unit_dto.dart';
import '../dto/currency_dto.dart';
import '../dto/metal_dto.dart';
import '../mappers/unit_mapper.dart';
import '../mappers/currency_mapper.dart';
import '../mappers/metal_mapper.dart';

class DiccionarioRepositoryImpl implements DiccionarioRepository {
  DiccionarioRepositoryImpl(this._ds);
  final DiccionarioDatasource _ds;

  @override
  Future<List<UnitEntity>> unidades() async {
    final data = await _ds.unidades();
    return data
        .map((e) => UnitMapper.fromDto(UnitDto.fromJson(e)))
        .toList();
  }

  @override
  Future<List<CurrencyEntity>> monedas() async {
    final data = await _ds.monedas();
    return data
        .map((e) => CurrencyMapper.fromDto(CurrencyDto.fromJson(e)))
        .toList();
  }

  @override
  Future<List<MetalEntity>> metales() async {
    final data = await _ds.metales();
    return data
        .map((e) => MetalMapper.fromDto(MetalDto.fromJson(e)))
        .toList();
  }
}
