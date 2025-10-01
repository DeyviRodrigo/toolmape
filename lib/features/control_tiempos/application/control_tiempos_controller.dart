import 'dart:async';
import 'package:uuid/uuid.dart';

import '../domain/models/control_tiempos_models.dart';

/// Controlador base que orquesta los catálogos y ciclos operativos.
class ControlTiemposController {
  ControlTiemposController() {
    _seedData();
    _emitAll();
  }

  final _uuid = const Uuid();

  final _dashboardController =
      StreamController<DashboardMetrics>.broadcast();
  final _ciclosController = StreamController<List<Ciclo>>.broadcast();
  final _equiposController = StreamController<List<Equipo>>.broadcast();
  final _chutesController = StreamController<List<Chute>>.broadcast();
  final _actividadesController = StreamController<List<Actividad>>.broadcast();

  final List<Ciclo> _ciclos = [];
  final List<Equipo> _equipos = [];
  final List<Chute> _chutes = [];
  final List<Actividad> _actividades = [];

  Stream<DashboardMetrics> get dashboardStream => _dashboardController.stream;
  Stream<List<Ciclo>> get ciclosStream =>
      _ciclosController.stream.transform(_sortCiclosTransformer());
  Stream<List<Equipo>> get equiposStream =>
      _equiposController.stream.transform(_sortEquiposTransformer());
  Stream<List<Chute>> get chutesStream =>
      _chutesController.stream.transform(_sortChutesTransformer());
  Stream<List<Actividad>> get actividadesStream =>
      _actividadesController.stream.transform(_sortActividadesTransformer());

  void dispose() {
    _dashboardController.close();
    _ciclosController.close();
    _equiposController.close();
    _chutesController.close();
    _actividadesController.close();
  }

  String generarId() => _uuid.v4();

  void _seedData() {
    final actividadesBase = [
      Actividad(id: 'act-carga', nombre: 'Carga', abreviatura: 'CARG'),
      Actividad(id: 'act-descarga', nombre: 'Descarga', abreviatura: 'DESC'),
      Actividad(id: 'act-traslado', nombre: 'Traslado', abreviatura: 'TRAS'),
      Actividad(id: 'act-espera', nombre: 'Espera', abreviatura: 'ESP'),
    ];
    _actividades.addAll(actividadesBase);

    _equipos.addAll([
      Equipo(
        id: 'eq-001',
        codigo: 'EQ-001',
        tipo: TipoEquipo.cargador,
        nombre: 'Cargador Komatsu',
        modelo: 'WA900',
        activo: true,
      ),
      Equipo(
        id: 'eq-002',
        codigo: 'EQ-002',
        tipo: TipoEquipo.excavadora,
        nombre: 'Excavadora Hitachi',
        modelo: 'ZX870',
        activo: true,
      ),
      Equipo(
        id: 'eq-003',
        codigo: 'EQ-003',
        tipo: TipoEquipo.volquete,
        nombre: 'Volquete CAT',
        modelo: '793F',
        activo: true,
      ),
    ]);

    _chutes.addAll([
      Chute(id: 'ch-01', nombre: 'Chute Norte', ubicacion: 'Zona A'),
      Chute(id: 'ch-02', nombre: 'Chute Sur', ubicacion: 'Zona B'),
    ]);

    final now = DateTime.now();
    _ciclos.addAll([
      Ciclo(
        id: 'cic-1',
        equipoId: 'eq-001',
        actividadId: 'act-carga',
        inicio: now.subtract(const Duration(hours: 2, minutes: 30)),
        fin: now.subtract(const Duration(hours: 2)),
        observaciones: 'Ciclo completado sin incidencias.',
      ),
      Ciclo(
        id: 'cic-2',
        equipoId: 'eq-002',
        actividadId: 'act-descarga',
        inicio: now.subtract(const Duration(hours: 1, minutes: 20)),
        fin: now.subtract(const Duration(hours: 1)),
      ),
      Ciclo(
        id: 'cic-3',
        equipoId: 'eq-003',
        actividadId: 'act-traslado',
        inicio: now.subtract(const Duration(minutes: 45)),
      ),
    ]);
  }

  void iniciarCiclo({
    required String equipoId,
    required String actividadId,
    String? chuteId,
    required DateTime inicio,
    DateTime? fin,
    Duration? tiempoMuerto,
    String? observaciones,
  }) {
    if (_ciclos.any(
      (c) => c.equipoId == equipoId && c.estado == CicloEstado.enProceso,
    )) {
      throw ControlTiemposException(
        'El equipo seleccionado ya tiene un ciclo en proceso.',
      );
    }

    if (fin != null && fin.isBefore(inicio)) {
      throw ControlTiemposException(
        'La fecha/hora final no puede ser menor a la inicial.',
      );
    }

    if (tiempoMuerto != null && fin != null) {
      final calculado = fin.difference(inicio);
      if (tiempoMuerto > calculado) {
        throw ControlTiemposException(
          'El tiempo muerto no puede exceder al tiempo calculado.',
        );
      }
    }

    final ciclo = Ciclo(
      id: generarId(),
      equipoId: equipoId,
      actividadId: actividadId,
      chuteId: chuteId,
      inicio: inicio,
      fin: fin,
      tiempoMuerto: tiempoMuerto,
      observaciones: observaciones,
    );

    _ciclos.add(ciclo);
    _emitAll();
  }

  void finalizarCiclo({
    required String cicloId,
    required DateTime fin,
    Duration? tiempoMuerto,
  }) {
    final ciclo = _firstWhereOrNull(_ciclos, (c) => c.id == cicloId);
    if (ciclo == null) {
      throw ControlTiemposException('No se encontró el ciclo seleccionado.');
    }

    if (fin.isBefore(ciclo.inicio)) {
      throw ControlTiemposException(
        'La fecha/hora final no puede ser menor a la inicial.',
      );
    }

    if (tiempoMuerto != null && tiempoMuerto > fin.difference(ciclo.inicio)) {
      throw ControlTiemposException(
        'El tiempo muerto no puede exceder al tiempo calculado.',
      );
    }

    ciclo
      ..fin = fin
      ..tiempoMuerto = tiempoMuerto
      ..enPausa = false;
    _emitAll();
  }

  void registrarPausa({
    required String cicloId,
    required Duration tiempoMuerto,
  }) {
    final ciclo = _firstWhereOrNull(_ciclos, (c) => c.id == cicloId);
    if (ciclo == null) {
      throw ControlTiemposException('No se encontró el ciclo seleccionado.');
    }

    final calculado = DateTime.now().difference(ciclo.inicio);
    if (tiempoMuerto > calculado) {
      throw ControlTiemposException(
        'El tiempo muerto no puede exceder al tiempo calculado.',
      );
    }

    ciclo
      ..tiempoMuerto = tiempoMuerto
      ..enPausa = true;
    _emitAll();
  }

  void actualizarEstadoManual(String cicloId, {required bool enPausa}) {
    final ciclo = _firstWhereOrNull(_ciclos, (c) => c.id == cicloId);
    if (ciclo != null) {
      ciclo.enPausa = enPausa;
      _emitAll();
    }
  }

  void eliminarCiclo(String cicloId) {
    _ciclos.removeWhere((c) => c.id == cicloId);
    _emitAll();
  }

  void upsertEquipo(Equipo equipo) {
    final index = _equipos.indexWhere((e) => e.id == equipo.id);
    if (index >= 0) {
      _equipos[index]
        ..codigo = equipo.codigo
        ..tipo = equipo.tipo
        ..nombre = equipo.nombre
        ..modelo = equipo.modelo
        ..activo = equipo.activo;
    } else {
      _equipos.add(equipo);
    }
    _emitAll();
  }

  void eliminarEquipo(String id) {
    _equipos.removeWhere((e) => e.id == id);
    _ciclos.removeWhere((c) => c.equipoId == id);
    _emitAll();
  }

  void upsertChute(Chute chute) {
    final index = _chutes.indexWhere((c) => c.id == chute.id);
    if (index >= 0) {
      _chutes[index]
        ..nombre = chute.nombre
        ..ubicacion = chute.ubicacion;
    } else {
      _chutes.add(chute);
    }
    _emitAll();
  }

  void eliminarChute(String id) {
    _chutes.removeWhere((c) => c.id == id);
    _emitAll();
  }

  void upsertActividad(Actividad actividad) {
    final index = _actividades.indexWhere((a) => a.id == actividad.id);
    if (index >= 0) {
      _actividades[index]
        ..nombre = actividad.nombre
        ..abreviatura = actividad.abreviatura;
    } else {
      _actividades.add(actividad);
    }
    _emitAll();
  }

  void eliminarActividad(String id) {
    _actividades.removeWhere((a) => a.id == id);
    _emitAll();
  }

  Equipo? equipoPorId(String id) =>
      _firstWhereOrNull(_equipos, (equipo) => equipo.id == id);
  Actividad? actividadPorId(String id) =>
      _firstWhereOrNull(_actividades, (actividad) => actividad.id == id);
  Chute? chutePorId(String id) =>
      _firstWhereOrNull(_chutes, (chute) => chute.id == id);

  void _emitAll() {
    _emitDashboard();
    _ciclosController.add(List.unmodifiable(_ciclos));
    _equiposController.add(List.unmodifiable(_equipos));
    _chutesController.add(List.unmodifiable(_chutes));
    _actividadesController.add(List.unmodifiable(_actividades));
  }

  void _emitDashboard() {
    final now = DateTime.now();
    final inicioHoy = DateTime(now.year, now.month, now.day);
    final completadosHoy = _ciclos
        .where((c) => c.fin != null && c.fin!.isAfter(inicioHoy))
        .toList();

    final promedio = completadosHoy.isEmpty
        ? Duration.zero
        : completadosHoy
                .map((c) => c.tiempoCalculado)
                .reduce((a, b) => a + b) ~/
            completadosHoy.length;

    final activosPorTipo = <TipoEquipo, Set<String>>{};
    for (final ciclo in _ciclos.where((c) => c.estado == CicloEstado.enProceso)) {
      final equipo = equipoPorId(ciclo.equipoId);
      if (equipo == null) continue;
      activosPorTipo.putIfAbsent(equipo.tipo, () => <String>{}).add(equipo.id);
    }

    final tiemposPorEquipo = List<Ciclo>.from(_ciclos)
      ..sort((a, b) =>
          (b.fin ?? b.inicio).compareTo(a.fin ?? a.inicio));

    final metrics = DashboardMetrics(
      cicloPromedio: promedio,
      ciclosCompletadosHoy: completadosHoy.length,
      ciclosEnProceso:
          _ciclos.where((c) => c.estado == CicloEstado.enProceso).length,
      equiposActivos: activosPorTipo.map(
        (key, value) => MapEntry(key, value.length),
      ),
      tiemposPorEquipo: tiemposPorEquipo,
    );

    _dashboardController.add(metrics);
  }

  StreamTransformer<List<Ciclo>, List<Ciclo>> _sortCiclosTransformer() =>
      StreamTransformer.fromHandlers(handleData: (data, sink) {
        final sorted = List<Ciclo>.from(data)
          ..sort((a, b) =>
              (b.fin ?? b.inicio).compareTo(a.fin ?? a.inicio));
        sink.add(sorted);
      });

  StreamTransformer<List<Equipo>, List<Equipo>> _sortEquiposTransformer() =>
      StreamTransformer.fromHandlers(handleData: (data, sink) {
        final sorted = List<Equipo>.from(data)
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        sink.add(sorted);
      });

  StreamTransformer<List<Chute>, List<Chute>> _sortChutesTransformer() =>
      StreamTransformer.fromHandlers(handleData: (data, sink) {
        final sorted = List<Chute>.from(data)
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        sink.add(sorted);
      });

  StreamTransformer<List<Actividad>, List<Actividad>>
      _sortActividadesTransformer() =>
          StreamTransformer.fromHandlers(handleData: (data, sink) {
        final sorted = List<Actividad>.from(data)
          ..sort((a, b) => a.nombre.compareTo(b.nombre));
        sink.add(sorted);
      });

  T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T element) test) {
    for (final element in items) {
      if (test(element)) return element;
    }
    return null;
  }
}
