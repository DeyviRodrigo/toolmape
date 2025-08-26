import '../repositories/mis_eventos_repository.dart';

/// Use case to create a personal calendar event.
class CrearEvento {
  CrearEvento(this._repo);
  final MisEventosRepository _repo;

  Future<void> call({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) {
    return _repo.crear(
      titulo: titulo,
      descripcion: descripcion,
      inicio: inicio,
      fin: fin,
      allDay: allDay,
    );
  }
}
