import '../../domain/entities/calculator_prefs_entity.dart';
import '../../domain/repositories/preferencias_repository.dart';
import '../datasources/preferencias_local_ds.dart';

class PreferenciasRepositoryImpl implements PreferenciasRepository {
  final PreferenciasLocalDatasource local;
  PreferenciasRepositoryImpl(this.local);

  @override
  Future<CalculatorPrefs> load() => local.load();

  @override
  Future<void> save(CalculatorPrefs prefs) => local.save(prefs);
}
