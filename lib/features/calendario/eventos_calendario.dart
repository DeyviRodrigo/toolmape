/// Clase: EventoCalendar - modelo de evento general del calendario.
class EventoCalendar {
  final String id;
  final String titulo;
  final String? descripcion;
  final String? categoria;
  final DateTime? inicio;       // ventana
  final DateTime? fin;          // ventana
  final DateTime? recordatorio; // fecha única (3 días antes por defecto en BD)
  final Map<String, dynamic> alcance; // filtros
  final String? fuente;

  EventoCalendar({
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

  factory EventoCalendar.fromMap(Map<String, dynamic> m) => EventoCalendar(
    id: m['id'] as String,
    titulo: m['titulo'] as String,
    descripcion: m['descripcion'] as String?,
    categoria: m['categoria'] as String?,
    inicio: m['inicio'] != null ? DateTime.parse(m['inicio'] as String) : null,
    fin: m['fin'] != null ? DateTime.parse(m['fin'] as String) : null,
    recordatorio: m['recordatorio'] != null ? DateTime.parse(m['recordatorio'] as String) : null,
    alcance: (m['alcance'] as Map?)?.cast<String, dynamic>() ?? const {},
    fuente: m['fuente'] as String?,
  );

  /// Función: aplicaA - verifica si el evento aplica al usuario.
  bool aplicaA({int? rucDigit, String? regimen}) {
    final digits = (alcance['ruc_digits'] as List?)?.cast<int>();
    if (digits != null && digits.isNotEmpty && rucDigit != null && !digits.contains(rucDigit)) return false;
    final regs = (alcance['regimen'] as List?)?.cast<String>();
    if (regs != null && regs.isNotEmpty && regimen != null && !regs.contains(regimen)) return false;
    return true;
  }
}
