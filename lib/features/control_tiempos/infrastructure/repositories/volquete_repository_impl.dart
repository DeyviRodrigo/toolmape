import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/domain/repositories/volquete_repository.dart';
import 'package:toolmape/features/control_tiempos/infrastructure/datasources/volquete_local_datasource.dart';

/// Implementación del repositorio utilizando un datasource local simulado.
class VolqueteRepositoryImpl implements VolqueteRepository {
  VolqueteRepositoryImpl(this._datasource);

  final VolqueteLocalDatasource _datasource;

  @override
  Future<List<Volquete>> obtenerVolquetes() {
    return _datasource.obtenerVolquetes();
  }
}
