class MiEventoEntity {
  final String id;
  final String userId;
  final String titulo;
  final String? descripcion;
  final DateTime inicio;
  final DateTime? fin;
  final bool allDay;

  MiEventoEntity({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.allDay,
  });
}
