import 'package:flutter/material.dart';

/// Tipos posibles de equipo para el control de tiempos.
enum TipoEquipo { cargador, excavadora, volquete }

/// Estados posibles de un ciclo operativo.
enum CicloEstado { enProceso, pausado, completado }

/// Modelo que representa un equipo/maquinaria dentro del sistema.
class Equipo {
  Equipo({
    required this.id,
    required this.codigo,
    required this.tipo,
    required this.nombre,
    required this.modelo,
    required this.activo,
  });

  final String id;
  String codigo;
  TipoEquipo tipo;
  String nombre;
  String modelo;
  bool activo;
}

/// Modelo de chute disponible para operaciones.
class Chute {
  Chute({
    required this.id,
    required this.nombre,
    required this.ubicacion,
  });

  final String id;
  String nombre;
  String ubicacion;
}

/// Actividades disponibles a ser registradas.
class Actividad {
  Actividad({
    required this.id,
    required this.nombre,
    required this.abreviatura,
  });

  final String id;
  String nombre;
  String abreviatura;
}

/// Modelo que representa un ciclo operativo de maquinaria.
class Ciclo {
  Ciclo({
    required this.id,
    required this.equipoId,
    required this.actividadId,
    this.chuteId,
    required this.inicio,
    this.fin,
    this.tiempoMuerto,
    this.observaciones,
    this.enPausa = false,
  });

  final String id;
  final String equipoId;
  final String actividadId;
  final String? chuteId;
  final DateTime inicio;
  DateTime? fin;
  Duration? tiempoMuerto;
  String? observaciones;
  bool enPausa;

  CicloEstado get estado {
    if (enPausa) return CicloEstado.pausado;
    if (fin == null) return CicloEstado.enProceso;
    return CicloEstado.completado;
  }

  Duration get tiempoCalculado {
    final finalizacion = fin ?? DateTime.now();
    return finalizacion.difference(inicio);
  }

  Duration get tiempoProductivo {
    if (tiempoMuerto == null) return tiempoCalculado;
    return tiempoCalculado - tiempoMuerto!;
  }
}

/// Métricas generales mostradas en el dashboard.
class DashboardMetrics {
  DashboardMetrics({
    required this.cicloPromedio,
    required this.ciclosCompletadosHoy,
    required this.ciclosEnProceso,
    required this.equiposActivos,
    required this.tiemposPorEquipo,
  });

  final Duration cicloPromedio;
  final int ciclosCompletadosHoy;
  final int ciclosEnProceso;
  final Map<TipoEquipo, int> equiposActivos;
  final List<Ciclo> tiemposPorEquipo;
}

/// Representa un error controlado dentro del módulo.
class ControlTiemposException implements Exception {
  ControlTiemposException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Utilidad para obtener una etiqueta amigable del tipo de equipo.
String tipoEquipoLabel(TipoEquipo tipo) {
  switch (tipo) {
    case TipoEquipo.cargador:
      return 'Cargador';
    case TipoEquipo.excavadora:
      return 'Excavadora';
    case TipoEquipo.volquete:
      return 'Volquete';
  }
}

/// Obtiene un color asociado al estado del ciclo para las chips.
Color estadoChipColor(BuildContext context, CicloEstado estado) {
  final scheme = Theme.of(context).colorScheme;
  switch (estado) {
    case CicloEstado.enProceso:
      return scheme.primaryContainer;
    case CicloEstado.pausado:
      return scheme.tertiaryContainer;
    case CicloEstado.completado:
      return scheme.secondaryContainer;
  }
}
