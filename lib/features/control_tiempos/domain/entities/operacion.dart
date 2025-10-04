/// Estados disponibles para una operación de excavadora.
enum EstadoOperacion { completo, incompleto }

extension EstadoOperacionLabel on EstadoOperacion {
  String get label {
    switch (this) {
      case EstadoOperacion.completo:
        return 'Completo';
      case EstadoOperacion.incompleto:
        return 'Incompleto';
    }
  }

  bool get isCompleto => this == EstadoOperacion.completo;
}

/// Entidad que representa una operación registrada en el control de tiempos.
class Operacion {
  const Operacion({
    required this.id,
    required this.maquinaria,
    required this.chute,
    required this.actividad,
    required this.inicio,
    this.fin,
    this.volquete,
    this.observaciones,
    this.estado = EstadoOperacion.incompleto,
  });

  final String id;
  final String maquinaria;
  final int chute;
  final String actividad;
  final DateTime inicio;
  final DateTime? fin;
  final String? volquete;
  final String? observaciones;
  final EstadoOperacion estado;

  Operacion copyWith({
    String? id,
    String? maquinaria,
    int? chute,
    String? actividad,
    DateTime? inicio,
    DateTime? fin = _noChangeDate,
    String? volquete = _noChangeString,
    String? observaciones = _noChangeString,
    EstadoOperacion? estado,
  }) {
    return Operacion(
      id: id ?? this.id,
      maquinaria: maquinaria ?? this.maquinaria,
      chute: chute ?? this.chute,
      actividad: actividad ?? this.actividad,
      inicio: inicio ?? this.inicio,
      fin: identical(fin, _noChangeDate) ? this.fin : fin,
      volquete:
          identical(volquete, _noChangeString) ? this.volquete : volquete,
      observaciones: identical(observaciones, _noChangeString)
          ? this.observaciones
          : observaciones,
      estado: estado ?? this.estado,
    );
  }

}

const _noChangeDate = Object();
const _noChangeString = Object();
