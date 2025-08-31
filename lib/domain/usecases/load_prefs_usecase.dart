import '../entities/calculator_prefs_entity.dart';
import '../repositories/preferencias_repository.dart';

class LoadPrefs {
  final PreferenciasRepository repository;
  LoadPrefs(this.repository);

  Future<CalculatorPrefs> call() => repository.load();
}
