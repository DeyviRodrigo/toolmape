import '../entities/unit_entity.dart';
import '../entities/currency_entity.dart';
import '../entities/metal_entity.dart';

abstract class DiccionarioRepository {
  Future<List<UnitEntity>> unidades();
  Future<List<CurrencyEntity>> monedas();
  Future<List<MetalEntity>> metales();
}
