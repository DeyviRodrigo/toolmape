import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';

abstract class PreferenciasRepository {
  Future<CalculatorPrefs> load();
  Future<void> save(CalculatorPrefs prefs);
}
