class MiEventoDto {
  final String id;
  final String userId;
  final String titulo;
  final String? descripcion;
  final DateTime inicio;
  final DateTime? fin;
  final bool allDay;

  MiEventoDto({
    required this.id,
    required this.userId,
    required this.titulo,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.allDay,
  });

  factory MiEventoDto.fromJson(Map<String, dynamic> json) => MiEventoDto(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String?,
        inicio: DateTime.parse(json['inicio'] as String).toLocal(),
        fin: json['fin'] != null
            ? DateTime.parse(json['fin'] as String).toLocal()
            : null,
        allDay: (json['all_day'] ?? false) as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'titulo': titulo,
        'descripcion': descripcion,
        'inicio': inicio.toIso8601String(),
        'fin': fin?.toIso8601String(),
        'all_day': allDay,
      };
}
