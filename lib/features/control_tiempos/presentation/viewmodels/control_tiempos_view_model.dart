import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/app/di/di.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/domain/repositories/volquete_repository.dart';

final controlTiemposViewModelProvider =
    StateNotifierProvider<ControlTiemposViewModel, ControlTiemposState>((ref) {
  final repository = ref.watch(volqueteRepositoryProvider);
  return ControlTiemposViewModel(repository);
});

class ControlTiemposViewModel extends StateNotifier<ControlTiemposState> {
  ControlTiemposViewModel(this._repository)
      : super(ControlTiemposState.initial());

  final VolqueteRepository _repository;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded || state.isLoading) return;
    _loaded = true;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final volquetes = await _repository.obtenerVolquetes();
      final sorted = [...volquetes]
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
      state = state.copyWith(
        volquetes: sorted,
        isLoading: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar los volquetes.',
      );
    }
  }

  void changeEquipo(VolqueteEquipo equipo) {
    if (equipo == state.selectedEquipo) return;
    state = state.copyWith(selectedEquipo: equipo);
  }

  void changeTipo(VolqueteTipo tipo) {
    if (tipo == state.selectedTipo) return;
    state = state.copyWith(selectedTipo: tipo);
  }

  void updateSearchTerm(String term) {
    final value = term.trim();
    if (value == state.searchTerm) return;
    state = state.copyWith(searchTerm: value);
  }

  void clearSearch() {
    if (state.searchTerm.isEmpty) return;
    state = state.copyWith(searchTerm: '');
  }

  void upsertVolquete(Volquete volquete) {
    final updated = [...state.volquetes];
    final index = updated.indexWhere((element) => element.id == volquete.id);
    if (index >= 0) {
      updated[index] = volquete;
    } else {
      updated.add(volquete);
    }
    updated.sort((a, b) => b.fecha.compareTo(a.fecha));
    state = state.copyWith(volquetes: updated);
  }

  void deleteVolquete(String id) {
    final filtered = state.volquetes.where((volquete) => volquete.id != id).toList();
    if (filtered.length == state.volquetes.length) return;
    state = state.copyWith(volquetes: filtered);
  }
}

class ControlTiemposState {
  const ControlTiemposState({
    required this.volquetes,
    required this.isLoading,
    required this.errorMessage,
    required this.selectedEquipo,
    required this.selectedTipo,
    required this.searchTerm,
  });

  factory ControlTiemposState.initial() => const ControlTiemposState(
        volquetes: <Volquete>[],
        isLoading: false,
        errorMessage: null,
        selectedEquipo: VolqueteEquipo.cargador,
        selectedTipo: VolqueteTipo.carga,
        searchTerm: '',
      );

  final List<Volquete> volquetes;
  final bool isLoading;
  final String? errorMessage;
  final VolqueteEquipo selectedEquipo;
  final VolqueteTipo selectedTipo;
  final String searchTerm;

  List<Volquete> get filteredVolquetes {
    final term = searchTerm.toLowerCase();
    final filtered = volquetes.where((volquete) {
      if (volquete.equipo != selectedEquipo) return false;
      if (volquete.tipo != selectedTipo) return false;
      if (term.isEmpty) return true;
      return volquete.codigo.toLowerCase().contains(term) ||
          volquete.placa.toLowerCase().contains(term) ||
          volquete.operador.toLowerCase().contains(term);
    }).toList();
    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    return filtered;
  }

  ControlTiemposState copyWith({
    List<Volquete>? volquetes,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    VolqueteEquipo? selectedEquipo,
    VolqueteTipo? selectedTipo,
    String? searchTerm,
  }) {
    return ControlTiemposState(
      volquetes: volquetes ?? this.volquetes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      selectedEquipo: selectedEquipo ?? this.selectedEquipo,
      selectedTipo: selectedTipo ?? this.selectedTipo,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }
}

const _sentinel = Object();
