/// Clase: MiEvento - modelo para eventos privados del usuario.
class MiEvento {
  final String id;
  final String userId;
  final String titulo;
  final String? descripcion;
  final DateTime inicio;
  final DateTime? fin;
  final bool allDay;

  MiEvento({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.allDay,
  });

  factory MiEvento.fromMap(Map<String, dynamic> m) => MiEvento(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    titulo: m['titulo'] as String,
    descripcion: m['descripcion'] as String?,
    inicio: DateTime.parse(m['inicio'] as String).toLocal(),
    fin: m['fin'] != null ? DateTime.parse(m['fin'] as String).toLocal() : null,
    allDay: (m['all_day'] ?? false) as bool,
  );
}
