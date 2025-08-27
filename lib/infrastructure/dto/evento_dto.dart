class EventoDto {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? categoria;
  final DateTime? inicio;
  final DateTime? fin;
  final DateTime? recordatorio;
  final Map<String, dynamic> alcance;
  final String? fuente;

  EventoDto({
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

  factory EventoDto.fromJson(Map<String, dynamic> json) => EventoDto(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String?,
        categoria: json['categoria'] as String?,
        inicio:
            json['inicio'] != null ? DateTime.parse(json['inicio'] as String) : null,
        fin: json['fin'] != null ? DateTime.parse(json['fin'] as String) : null,
        recordatorio: json['recordatorio'] != null
            ? DateTime.parse(json['recordatorio'] as String)
            : null,
        alcance: (json['alcance'] as Map?)?.cast<String, dynamic>() ?? const {},
        fuente: json['fuente'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'inicio': inicio?.toIso8601String(),
        'fin': fin?.toIso8601String(),
        'recordatorio': recordatorio?.toIso8601String(),
        'alcance': alcance,
        'fuente': fuente,
      };
}
