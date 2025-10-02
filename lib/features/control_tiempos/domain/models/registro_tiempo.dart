import 'package:flutter/material.dart';

import 'package:toolmape/theme/app_colors.dart';

enum EquipoTipo { cargador, excavadora }

enum RegistroOperacion { carga, descarga }

enum RegistroEstado { completo, enProceso, pausado }

extension EquipoTipoLabel on EquipoTipo {
  String get label {
    switch (this) {
      case EquipoTipo.cargador:
        return 'Cargador';
      case EquipoTipo.excavadora:
        return 'Excavadora';
    }
  }
}

extension RegistroOperacionLabel on RegistroOperacion {
  String get label {
    switch (this) {
      case RegistroOperacion.carga:
        return 'Carga';
      case RegistroOperacion.descarga:
        return 'Descarga';
    }
  }
}

extension RegistroEstadoLabel on RegistroEstado {
  String get label {
    switch (this) {
      case RegistroEstado.completo:
        return 'Completo';
      case RegistroEstado.enProceso:
        return 'En proceso';
      case RegistroEstado.pausado:
        return 'Pausado';
    }
  }

  Color get color {
    switch (this) {
      case RegistroEstado.completo:
        return AppColors.success;
      case RegistroEstado.enProceso:
        return AppColors.warning;
      case RegistroEstado.pausado:
        return AppColors.primary;
    }
  }
}

class RegistroActividad {
  const RegistroActividad({
    required this.nombre,
    required this.descripcion,
    required this.fecha,
  });

  final String nombre;
  final String descripcion;
  final DateTime fecha;

  factory RegistroActividad.fromJson(Map<String, dynamic> json) {
    return RegistroActividad(
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha': fecha.toIso8601String(),
      };
}

class RegistroTiempo {
  const RegistroTiempo({
    required this.id,
    required this.volquete,
    required this.operador,
    required this.documento,
    required this.equipo,
    required this.operacion,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    required this.destino,
    required this.actividades,
    required this.observaciones,
  });

  final String id;
  final String volquete;
  final String operador;
  final String? documento;
  final EquipoTipo equipo;
  final RegistroOperacion operacion;
  final RegistroEstado estado;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String destino;
  final List<RegistroActividad> actividades;
  final String? observaciones;

  DateTime get fechaReferencia => fechaFin ?? fechaInicio;

  Duration? get duracion =>
      fechaFin == null ? null : fechaFin!.difference(fechaInicio);

  RegistroTiempo copyWith({
    String? id,
    String? volquete,
    String? operador,
    String? documento,
    EquipoTipo? equipo,
    RegistroOperacion? operacion,
    RegistroEstado? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? destino,
    List<RegistroActividad>? actividades,
    String? observaciones,
  }) {
    return RegistroTiempo(
      id: id ?? this.id,
      volquete: volquete ?? this.volquete,
      operador: operador ?? this.operador,
      documento: documento ?? this.documento,
      equipo: equipo ?? this.equipo,
      operacion: operacion ?? this.operacion,
      estado: estado ?? this.estado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      destino: destino ?? this.destino,
      actividades: actividades ?? this.actividades,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  factory RegistroTiempo.fromJson(Map<String, dynamic> json) {
    final estado = _estadoFromString(json['estado'] as String);
    return RegistroTiempo(
      id: json['id'] as String,
      volquete: json['volquete'] as String,
      operador: json['operador'] as String,
      documento: json['documento'] as String?,
      equipo: _equipoFromString(json['equipo'] as String),
      operacion: _operacionFromString(json['operacion'] as String),
      estado: estado,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: (json['fechaFin'] as String?)?.isEmpty ?? true
          ? null
          : DateTime.parse(json['fechaFin'] as String),
      destino: json['destino'] as String,
      actividades: (json['actividades'] as List<dynamic>)
          .map((dynamic item) =>
              RegistroActividad.fromJson(item as Map<String, dynamic>))
          .toList(),
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'volquete': volquete,
        'operador': operador,
        'documento': documento,
        'equipo': equipo.name,
        'operacion': operacion.name,
        'estado': estado.name,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin?.toIso8601String(),
        'destino': destino,
        'actividades': actividades.map((a) => a.toJson()).toList(),
        'observaciones': observaciones,
      };
}

EquipoTipo _equipoFromString(String value) {
  switch (value) {
    case 'cargador':
      return EquipoTipo.cargador;
    case 'excavadora':
      return EquipoTipo.excavadora;
    default:
      throw ArgumentError('Equipo desconocido: $value');
  }
}

RegistroOperacion _operacionFromString(String value) {
  switch (value) {
    case 'carga':
      return RegistroOperacion.carga;
    case 'descarga':
      return RegistroOperacion.descarga;
    default:
      throw ArgumentError('Operación desconocida: $value');
  }
}

RegistroEstado _estadoFromString(String value) {
  switch (value) {
    case 'completo':
      return RegistroEstado.completo;
    case 'en_proceso':
      return RegistroEstado.enProceso;
    case 'pausado':
      return RegistroEstado.pausado;
    default:
      throw ArgumentError('Estado desconocido: $value');
  }
}
