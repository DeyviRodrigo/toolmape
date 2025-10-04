import 'package:equatable/equatable.dart';

enum ExcavadoraEstado { incompleto, completo }

/// Entidad que representa un registro de operación de excavadora.
class ExcavadoraOperacion extends Equatable {
  const ExcavadoraOperacion({
    required this.id,
    required this.actividad,
    required this.maquinaria,
    required this.chute,
    required this.actividadId,
    required this.inicio,
    this.fin,
    this.volquete,
    this.observaciones,
  });

  /// Identificador del registro.
  final String id;

  /// Nombre de la actividad asociada (p.ej. "Carguío de Gravas").
  final String actividad;

  /// Identificador interno de la actividad (para listas desplegables).
  final String actividadId;

  /// Máquina asignada a la operación (p.ej. "(E01) Excav. C 340-01").
  final String maquinaria;

  /// Número de chute seleccionado (1 a 5).
  final int chute;

  /// Fecha y hora de inicio de la operación.
  final DateTime inicio;

  /// Fecha y hora de fin de la operación, si ya fue cerrada.
  final DateTime? fin;

  /// Volquete asociado, si aplica.
  final String? volquete;

  /// Observaciones ingresadas por el operador.
  final String? observaciones;

  ExcavadoraEstado get estado => fin == null
      ? ExcavadoraEstado.incompleto
      : ExcavadoraEstado.completo;

  bool get estaCompleta => estado == ExcavadoraEstado.completo;

  ExcavadoraOperacion copyWith({
    String? id,
    String? actividad,
    String? actividadId,
    String? maquinaria,
    int? chute,
    DateTime? inicio,
    DateTime? fin,
    String? volquete,
    String? observaciones,
    bool finNullable = false,
  }) {
    return ExcavadoraOperacion(
      id: id ?? this.id,
      actividad: actividad ?? this.actividad,
      actividadId: actividadId ?? this.actividadId,
      maquinaria: maquinaria ?? this.maquinaria,
      chute: chute ?? this.chute,
      inicio: inicio ?? this.inicio,
      fin: finNullable ? null : (fin ?? this.fin),
      volquete: volquete ?? this.volquete,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        actividad,
        actividadId,
        maquinaria,
        chute,
        inicio,
        fin,
        volquete,
        observaciones,
      ];
}
