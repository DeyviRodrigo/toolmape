import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

/// Datasource local con datos simulados para el módulo de control de tiempos.
class VolqueteLocalDatasource {
  Future<List<Volquete>> obtenerVolquetes() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _mockVolquetes.map((volquete) => volquete).toList();
  }
}

const List<Volquete> _mockVolquetes = [
  Volquete(
    id: 'v09',
    codigo: '(V09) Volq. JAA X3U-843',
    placa: 'JAA X3U-843',
    operador: 'Carlos Velarde',
    destino: 'Frente 12 - Zona A',
    fecha: DateTime(2025, 3, 27, 15, 30),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V09.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Carga completada',
        descripcion: 'Carga registrada por operador en turno matutino.',
        fecha: DateTime(2025, 3, 27, 15, 20),
      ),
      VolqueteEvento(
        titulo: 'Salida hacia depósito',
        descripcion: 'Salida autorizada con guía interna 000912.',
        fecha: DateTime(2025, 3, 27, 15, 30),
      ),
    ],
  ),
  Volquete(
    id: 'v05',
    codigo: '(V05) Volq. GQ VQN-840',
    placa: 'GQ VQN-840',
    operador: 'Ana Espino',
    destino: 'Depósito central',
    fecha: DateTime(2025, 3, 27, 14, 45),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V05.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a carguío',
        descripcion: 'Arribo al frente con orden de servicio 000234.',
        fecha: DateTime(2025, 3, 27, 14, 10),
      ),
      VolqueteEvento(
        titulo: 'Pesaje preliminar',
        descripcion: 'Peso registrado 18.2 tn.',
        fecha: DateTime(2025, 3, 27, 14, 40),
      ),
    ],
  ),
  Volquete(
    id: 'v02',
    codigo: '(V02) Volq. RD F7V-760',
    placa: 'RD F7V-760',
    operador: 'Luis Ramos',
    destino: 'Botadero norte',
    fecha: DateTime(2025, 3, 27, 13, 10),
    estado: VolqueteEstado.pausado,
    tipo: VolqueteTipo.carga,
    equipo: VolqueteEquipo.cargador,
    documento: 'OrdenCarga_V02.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Inicio de carga',
        descripcion: 'Inicio autorizado por supervisor.',
        fecha: DateTime(2025, 3, 27, 12, 50),
      ),
      VolqueteEvento(
        titulo: 'Pausa temporal',
        descripcion: 'En espera por mantenimiento del frente.',
        fecha: DateTime(2025, 3, 27, 13, 5),
      ),
    ],
  ),
  Volquete(
    id: 'v11',
    codigo: '(V11) Volq. JAA X3U-843',
    placa: 'JAA X3U-843',
    operador: 'Carlos Velarde',
    destino: 'Planta de chancado',
    fecha: DateTime(2025, 3, 27, 16, 10),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V11.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ruta asignada',
        descripcion: 'Excavadora CX-02 designada para descarga.',
        fecha: DateTime(2025, 3, 27, 15, 50),
      ),
      VolqueteEvento(
        titulo: 'Descarga iniciada',
        descripcion: 'Inicia maniobra en planta.',
        fecha: DateTime(2025, 3, 27, 16, 5),
      ),
    ],
  ),
  Volquete(
    id: 'v14',
    codigo: '(V14) Volq. GQ VQN-840',
    placa: 'GQ VQN-840',
    operador: 'Ana Espino',
    destino: 'Depósito temporal B',
    fecha: DateTime(2025, 3, 27, 11, 30),
    estado: VolqueteEstado.completo,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V14.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Ingreso a descarga',
        descripcion: 'Control de acceso completado.',
        fecha: DateTime(2025, 3, 27, 11, 5),
      ),
      VolqueteEvento(
        titulo: 'Descarga completada',
        descripcion: 'Material dispuesto en depósito temporal.',
        fecha: DateTime(2025, 3, 27, 11, 25),
      ),
    ],
  ),
  Volquete(
    id: 'v20',
    codigo: '(V20) Volq. RD F7V-760',
    placa: 'RD F7V-760',
    operador: 'Luis Ramos',
    destino: 'Botadero norte',
    fecha: DateTime(2025, 3, 27, 10, 45),
    estado: VolqueteEstado.enProceso,
    tipo: VolqueteTipo.descarga,
    equipo: VolqueteEquipo.excavadora,
    documento: 'OrdenDescarga_V20.pdf',
    eventos: [
      VolqueteEvento(
        titulo: 'Salida de planta',
        descripcion: 'Traslado con guía de transporte 001122.',
        fecha: DateTime(2025, 3, 27, 10, 20),
      ),
      VolqueteEvento(
        titulo: 'En ruta',
        descripcion: 'Esperando autorización para descarga.',
        fecha: DateTime(2025, 3, 27, 10, 40),
      ),
    ],
  ),
];
