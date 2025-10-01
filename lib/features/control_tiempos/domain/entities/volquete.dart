/// Posibles estados de un volquete dentro del flujo de control de tiempos.
enum VolqueteEstado { completo, enProceso, pausado }

extension VolqueteEstadoLabel on VolqueteEstado {
  String get label {
    switch (this) {
      case VolqueteEstado.completo:
        return 'Completo';
      case VolqueteEstado.enProceso:
        return 'En proceso';
      case VolqueteEstado.pausado:
        return 'Pausado';
    }
  }
}

/// Tipo de operación que está realizando el volquete.
enum VolqueteTipo { carga, descarga }

extension VolqueteTipoLabel on VolqueteTipo {
  String get label {
    switch (this) {
      case VolqueteTipo.carga:
        return 'Carga';
      case VolqueteTipo.descarga:
        return 'Descarga';
    }
  }
}

/// Equipos disponibles que pueden estar asociados a una operación.
enum VolqueteEquipo { cargador, excavadora }

extension VolqueteEquipoLabel on VolqueteEquipo {
  String get label {
    switch (this) {
      case VolqueteEquipo.cargador:
        return 'Cargador';
      case VolqueteEquipo.excavadora:
        return 'Excavadora';
    }
  }
}

/// Evento en la línea de tiempo del volquete.
class VolqueteEvento {
  const VolqueteEvento({
    required this.titulo,
    required this.descripcion,
    required this.fecha,
  });

  final String titulo;
  final String descripcion;
  final DateTime fecha;
}

/// Entidad de dominio simple para representar un volquete registrado.
class Volquete {
  const Volquete({
    required this.id,
    required this.codigo,
    required this.placa,
    required this.operador,
    required this.destino,
    required this.fecha,
    required this.estado,
    required this.tipo,
    required this.equipo,
    required this.eventos,
    this.documento,
    this.notas,
  });

  final String id;
  final String codigo;
  final String placa;
  final String operador;
  final String destino;
  final DateTime fecha;
  final VolqueteEstado estado;
  final VolqueteTipo tipo;
  final VolqueteEquipo equipo;
  final List<VolqueteEvento> eventos;
  final String? documento;
  final String? notas;

  Volquete copyWith({
    String? id,
    String? codigo,
    String? placa,
    String? operador,
    String? destino,
    DateTime? fecha,
    VolqueteEstado? estado,
    VolqueteTipo? tipo,
    VolqueteEquipo? equipo,
    List<VolqueteEvento>? eventos,
    String? documento,
    String? notas,
  }) {
    return Volquete(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      placa: placa ?? this.placa,
      operador: operador ?? this.operador,
      destino: destino ?? this.destino,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      tipo: tipo ?? this.tipo,
      equipo: equipo ?? this.equipo,
      eventos: eventos ?? this.eventos,
      documento: documento ?? this.documento,
      notas: notas ?? this.notas,
    );
  }
}
