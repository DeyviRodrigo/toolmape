import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/control_tiempos/domain/models/registro_tiempo.dart';
import 'package:toolmape/features/control_tiempos/domain/services/control_tiempos_service.dart';

const _sentinel = Object();

class ControlTiemposState {
  const ControlTiemposState({
    required this.registros,
    required this.isLoading,
    required this.errorMessage,
    required this.tabIndex,
    required this.operacion,
    required this.searchTerm,
  });

  factory ControlTiemposState.initial() {
    return const ControlTiemposState(
      registros: <RegistroTiempo>[],
      isLoading: false,
      errorMessage: null,
      tabIndex: 0,
      operacion: RegistroOperacion.carga,
      searchTerm: '',
    );
  }

  final List<RegistroTiempo> registros;
  final bool isLoading;
  final String? errorMessage;
  final int tabIndex;
  final RegistroOperacion operacion;
  final String searchTerm;

  EquipoTipo get equipoActual =>
      tabIndex == 0 ? EquipoTipo.cargador : EquipoTipo.excavadora;

  List<RegistroTiempo> get filtrados {
    final equipo = equipoActual;
    final query = searchTerm.trim().toLowerCase();
    final List<RegistroTiempo> filtrados = registros.where((registro) {
      if (registro.equipo != equipo) return false;
      if (registro.operacion != operacion) return false;
      if (query.isEmpty) return true;
      return registro.volquete.toLowerCase().contains(query) ||
          registro.operador.toLowerCase().contains(query);
    }).toList();
    filtrados.sort(
      (a, b) => b.fechaReferencia.compareTo(a.fechaReferencia),
    );
    return filtrados;
  }

  ControlTiemposState copyWith({
    List<RegistroTiempo>? registros,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? tabIndex,
    RegistroOperacion? operacion,
    String? searchTerm,
  }) {
    return ControlTiemposState(
      registros: registros ?? this.registros,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      tabIndex: tabIndex ?? this.tabIndex,
      operacion: operacion ?? this.operacion,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

class ControlTiemposController extends StateNotifier<ControlTiemposState> {
  ControlTiemposController({required ControlTiemposService service})
      : _service = service,
        super(ControlTiemposState.initial());

  final ControlTiemposService _service;

  Future<void> cargar() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final registros = await _service.obtenerRegistros();
      state = state.copyWith(
        registros: registros,
        isLoading: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar los registros.',
      );
    }
  }

  void setTab(int index) {
    if (index == state.tabIndex) return;
    state = state.copyWith(tabIndex: index);
  }

  void setOperacion(RegistroOperacion operacion) {
    if (operacion == state.operacion) return;
    state = state.copyWith(operacion: operacion);
  }

  void onSearch(String term) {
    state = state.copyWith(searchTerm: term);
  }

  Future<void> eliminar(String id) async {
    await _service.eliminarRegistro(id);
    final registros =
        state.registros.where((registro) => registro.id != id).toList();
    state = state.copyWith(registros: registros);
  }

  ControlTiemposService get service => _service;
}

final controlTiemposServiceProvider = Provider<ControlTiemposService>((ref) {
  return ControlTiemposService();
});

final controlTiemposControllerProvider =
    StateNotifierProvider<ControlTiemposController, ControlTiemposState>((ref) {
  final service = ref.watch(controlTiemposServiceProvider);
  return ControlTiemposController(service: service);
});
