import '../entities/calculator_prefs_entity.dart';
import '../repositories/preferencias_repository.dart';

class SavePrefs {
  final PreferenciasRepository repository;
  SavePrefs(this.repository);

  Future<void> call(CalculatorPrefs prefs) => repository.save(prefs);
}
