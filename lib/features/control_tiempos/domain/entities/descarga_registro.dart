/// Estado de un registro de descarga.
enum DescargaEstado { completo, incompleto }

extension DescargaEstadoLabel on DescargaEstado {
  String get label {
    switch (this) {
      case DescargaEstado.completo:
        return 'Completo';
      case DescargaEstado.incompleto:
        return 'Incompleto';
    }
  }
}

/// Entidad que representa un registro de descarga de un volquete.
class DescargaRegistro {
  const DescargaRegistro({
    required this.id,
    required this.volquete,
    required this.volqueteAlias,
    required this.maquinaria,
    required this.procedencia,
    required this.chute,
    required this.llegadaChute,
    this.inicioDescarga,
    this.finalDescarga,
    this.salidaChute,
    this.observaciones,
    required this.estado,
  });

  final String id;
  final String volquete;
  final String volqueteAlias;
  final String maquinaria;
  final String procedencia;
  final int chute;
  final DateTime llegadaChute;
  final DateTime? inicioDescarga;
  final DateTime? finalDescarga;
  final DateTime? salidaChute;
  final String? observaciones;
  final DescargaEstado estado;

  DescargaRegistro copyWith({
    String? id,
    String? volquete,
    String? volqueteAlias,
    String? maquinaria,
    String? procedencia,
    int? chute,
    DateTime? llegadaChute,
    DateTime? inicioDescarga,
    DateTime? finalDescarga,
    DateTime? salidaChute,
    String? observaciones,
    DescargaEstado? estado,
  }) {
    return DescargaRegistro(
      id: id ?? this.id,
      volquete: volquete ?? this.volquete,
      volqueteAlias: volqueteAlias ?? this.volqueteAlias,
      maquinaria: maquinaria ?? this.maquinaria,
      procedencia: procedencia ?? this.procedencia,
      chute: chute ?? this.chute,
      llegadaChute: llegadaChute ?? this.llegadaChute,
      inicioDescarga: inicioDescarga ?? this.inicioDescarga,
      finalDescarga: finalDescarga ?? this.finalDescarga,
      salidaChute: salidaChute ?? this.salidaChute,
      observaciones: observaciones ?? this.observaciones,
      estado: estado ?? this.estado,
    );
  }

}

/// Datos simulados para presentar el flujo de descargas.
final List<DescargaRegistro> kDescargasDemo = [
  DescargaRegistro(
    id: 'd1',
    volquete: '(V09) Volqu. JAA X3U-843',
    volqueteAlias: 'Volquete JAA X3U-843',
    maquinaria: '(E01) Excavadora C340-01',
    procedencia: 'Beatriz 1',
    chute: 3,
    llegadaChute: DateTime(2025, 7, 23, 9, 25, 28),
    inicioDescarga: DateTime(2025, 7, 23, 9, 31, 21),
    finalDescarga: DateTime(2025, 7, 23, 9, 45, 31),
    salidaChute: DateTime(2025, 7, 23, 9, 58, 57),
    observaciones: 'Sin observaciones.',
    estado: DescargaEstado.completo,
  ),
  DescargaRegistro(
    id: 'd2',
    volquete: '(V10) Volqu. MG B9G-917',
    volqueteAlias: 'Volquete MG B9G-917',
    maquinaria: '(E02) Excavadora ZX-350',
    procedencia: 'Panchita 2',
    chute: 4,
    llegadaChute: DateTime(2025, 7, 22, 8, 45, 12),
    inicioDescarga: DateTime(2025, 7, 22, 8, 50, 30),
    finalDescarga: DateTime(2025, 7, 22, 9, 5, 42),
    salidaChute: DateTime(2025, 7, 22, 9, 18, 12),
    observaciones: 'Descarga coordinada con turno B.',
    estado: DescargaEstado.completo,
  ),
  DescargaRegistro(
    id: 'd3',
    volquete: '(V08) Volqu. GQ VQN-840',
    volqueteAlias: 'Volquete GQ VQN-840',
    maquinaria: '(E03) Excavadora SK-500',
    procedencia: 'Depósito central',
    chute: 2,
    llegadaChute: DateTime(2025, 7, 23, 9, 27, 35),
    inicioDescarga: DateTime(2025, 7, 23, 9, 33, 11),
    finalDescarga: null,
    salidaChute: null,
    observaciones: 'Esperando autorización para retiro.',
    estado: DescargaEstado.incompleto,
  ),
  DescargaRegistro(
    id: 'd4',
    volquete: '(V06) Volqu. FR D7V-760',
    volqueteAlias: 'Volquete FR D7V-760',
    maquinaria: '(E01) Excavadora C340-01',
    procedencia: 'Frente Norte',
    chute: 1,
    llegadaChute: DateTime(2025, 7, 22, 15, 40, 0),
    inicioDescarga: DateTime(2025, 7, 22, 15, 46, 15),
    finalDescarga: DateTime(2025, 7, 22, 15, 58, 44),
    salidaChute: DateTime(2025, 7, 22, 16, 3, 19),
    observaciones: 'Se retiró cobertura plástica.',
    estado: DescargaEstado.completo,
  ),
  DescargaRegistro(
    id: 'd5',
    volquete: '(V04) Volqu. SR V3R-770',
    volqueteAlias: 'Volquete SR V3R-770',
    maquinaria: '(E04) Excavadora DX-420',
    procedencia: 'Pampa Sur',
    chute: 5,
    llegadaChute: DateTime(2025, 7, 16, 18, 5, 47),
    inicioDescarga: DateTime(2025, 7, 16, 18, 12, 30),
    finalDescarga: DateTime(2025, 7, 16, 18, 28, 3),
    salidaChute: DateTime(2025, 7, 16, 18, 35, 14),
    observaciones: 'Verificar calibración de báscula.',
    estado: DescargaEstado.completo,
  ),
  DescargaRegistro(
    id: 'd6',
    volquete: '(V12) Volqu. FR D7V-760',
    volqueteAlias: 'Volquete FR D7V-760',
    maquinaria: '(E01) Excavadora C340-01',
    procedencia: 'Botadero Norte',
    chute: 2,
    llegadaChute: DateTime(2025, 7, 18, 10, 22, 10),
    inicioDescarga: DateTime(2025, 7, 18, 10, 32, 5),
    finalDescarga: null,
    salidaChute: null,
    observaciones: 'Pendiente completar maniobra.',
    estado: DescargaEstado.incompleto,
  ),
  DescargaRegistro(
    id: 'd7',
    volquete: '(V03) Volqu. MG B9G-917',
    volqueteAlias: 'Volquete MG B9G-917',
    maquinaria: '(E02) Excavadora ZX-350',
    procedencia: 'Beatriz 2',
    chute: 4,
    llegadaChute: DateTime(2025, 7, 21, 7, 55, 0),
    inicioDescarga: DateTime(2025, 7, 21, 8, 2, 45),
    finalDescarga: DateTime(2025, 7, 21, 8, 19, 2),
    salidaChute: DateTime(2025, 7, 21, 8, 28, 19),
    observaciones: 'Coordinado con supervisión.',
    estado: DescargaEstado.completo,
  ),
  DescargaRegistro(
    id: 'd8',
    volquete: '(V01) Volqu. GG VON-840',
    volqueteAlias: 'Volquete GG VON-840',
    maquinaria: '(E05) Excavadora PC-400',
    procedencia: 'Depósito temporal B',
    chute: 1,
    llegadaChute: DateTime(2025, 7, 23, 15, 51, 1),
    inicioDescarga: DateTime(2025, 7, 23, 15, 56, 40),
    finalDescarga: null,
    salidaChute: null,
    observaciones: 'A la espera de vaciado final.',
    estado: DescargaEstado.incompleto,
  ),
];
