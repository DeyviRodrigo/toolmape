import '../value_objects/event_scope.dart';

class EventoEntity {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? categoria;
  final DateTime? inicio;
  final DateTime? fin;
  final DateTime? recordatorio;
  final EventScope alcance;
  final String? fuente;

  EventoEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.inicio,
    required this.fin,
    required this.recordatorio,
    required this.alcance,
    required this.fuente,
  });
}
