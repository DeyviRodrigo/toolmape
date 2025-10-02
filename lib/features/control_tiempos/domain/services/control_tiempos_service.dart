import 'dart:convert';

import 'package:toolmape/features/control_tiempos/domain/models/registro_tiempo.dart';

/// Servicio en memoria que simula las operaciones del backend.
class ControlTiemposService {
  ControlTiemposService() : _registros = _initialRegistros();

  final List<RegistroTiempo> _registros;

  Future<List<RegistroTiempo>> obtenerRegistros() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<RegistroTiempo>.unmodifiable(_registros);
  }

  Future<RegistroTiempo> crearRegistro(RegistroTiempo registro) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final nuevo = registro.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _registros.add(nuevo);
    return nuevo;
  }

  Future<RegistroTiempo> actualizarRegistro(RegistroTiempo registro) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _registros.indexWhere((element) => element.id == registro.id);
    if (index == -1) {
      throw StateError('Registro no encontrado');
    }
    _registros[index] = registro;
    return registro;
  }

  Future<void> eliminarRegistro(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _registros.removeWhere((element) => element.id == id);
  }

  Future<void> generarPdf(RegistroTiempo registro) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  static List<RegistroTiempo> _initialRegistros() {
    final List<dynamic> decoded = jsonDecode(_mockJson) as List<dynamic>;
    return decoded
        .map((dynamic item) =>
            RegistroTiempo.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

const String _mockJson = '''
[
  {
    "id": "1",
    "volquete": "(V05) Volq. GQ VQN-840",
    "operador": "Ana Espino",
    "documento": "OrdenCarga_V05.pdf",
    "equipo": "cargador",
    "operacion": "carga",
    "estado": "en_proceso",
    "fechaInicio": "2025-03-27T14:10:00.000",
    "fechaFin": "",
    "destino": "Depósito central",
    "actividades": [
      {
        "nombre": "Ingreso a carguío",
        "descripcion": "Arribo al frente con orden de servicio 000234.",
        "fecha": "2025-03-27T14:10:00.000"
      },
      {
        "nombre": "Pesaje preliminar",
        "descripcion": "Peso registrado 18.2 tn.",
        "fecha": "2025-03-27T14:40:00.000"
      }
    ],
    "observaciones": "Esperando confirmación de laboratorio."
  },
  {
    "id": "2",
    "volquete": "(V02) Volq. RD F7V-760",
    "operador": "Luis Ramos",
    "documento": "OrdenCarga_V02.pdf",
    "equipo": "cargador",
    "operacion": "carga",
    "estado": "pausado",
    "fechaInicio": "2025-03-27T12:50:00.000",
    "fechaFin": "",
    "destino": "Botadero norte",
    "actividades": [
      {
        "nombre": "Inicio de carga",
        "descripcion": "Inicio autorizado por supervisor.",
        "fecha": "2025-03-27T12:50:00.000"
      },
      {
        "nombre": "Pausa temporal",
        "descripcion": "En espera por mantenimiento del frente.",
        "fecha": "2025-03-27T13:05:00.000"
      }
    ],
    "observaciones": "Se coordina reanudación en 15 minutos."
  },
  {
    "id": "3",
    "volquete": "(V11) Volq. JAA X3U-843",
    "operador": "Carlos Velarde",
    "documento": "OrdenDescarga_V11.pdf",
    "equipo": "excavadora",
    "operacion": "descarga",
    "estado": "en_proceso",
    "fechaInicio": "2025-03-27T15:50:00.000",
    "fechaFin": "",
    "destino": "Planta de chancado",
    "actividades": [
      {
        "nombre": "Ruta asignada",
        "descripcion": "Excavadora CX-02 designada para descarga.",
        "fecha": "2025-03-27T15:50:00.000"
      },
      {
        "nombre": "Descarga iniciada",
        "descripcion": "Inicia maniobra en planta.",
        "fecha": "2025-03-27T16:05:00.000"
      }
    ],
    "observaciones": "Supervisión solicita registro fotográfico."
  },
  {
    "id": "4",
    "volquete": "(V14) Volq. GQ VQN-840",
    "operador": "Ana Espino",
    "documento": "OrdenDescarga_V14.pdf",
    "equipo": "excavadora",
    "operacion": "descarga",
    "estado": "completo",
    "fechaInicio": "2025-03-27T11:05:00.000",
    "fechaFin": "2025-03-27T11:25:00.000",
    "destino": "Depósito temporal B",
    "actividades": [
      {
        "nombre": "Ingreso a descarga",
        "descripcion": "Control de acceso completado.",
        "fecha": "2025-03-27T11:05:00.000"
      },
      {
        "nombre": "Descarga completada",
        "descripcion": "Material dispuesto en depósito temporal.",
        "fecha": "2025-03-27T11:25:00.000"
      }
    ],
    "observaciones": "Sin novedades."
  },
  {
    "id": "5",
    "volquete": "(V20) Volq. RD F7V-760",
    "operador": "Luis Ramos",
    "documento": "OrdenDescarga_V20.pdf",
    "equipo": "excavadora",
    "operacion": "descarga",
    "estado": "en_proceso",
    "fechaInicio": "2025-03-27T10:20:00.000",
    "fechaFin": "",
    "destino": "Botadero norte",
    "actividades": [
      {
        "nombre": "Salida de planta",
        "descripcion": "Traslado con guía de transporte 001122.",
        "fecha": "2025-03-27T10:20:00.000"
      },
      {
        "nombre": "En ruta",
        "descripcion": "Esperando autorización para descarga.",
        "fecha": "2025-03-27T10:40:00.000"
      }
    ],
    "observaciones": "Coordinación con seguridad en curso."
  }
]
''';
