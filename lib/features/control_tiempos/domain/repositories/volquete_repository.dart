import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

/// Contrato del repositorio para gestionar los volquetes del módulo.
abstract class VolqueteRepository {
  /// Obtiene la lista de volquetes registrados.
  Future<List<Volquete>> obtenerVolquetes();
}
