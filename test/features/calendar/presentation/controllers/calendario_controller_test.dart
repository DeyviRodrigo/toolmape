import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/features/calendar/presentation/controllers/calendario_controller.dart';
import 'package:toolmape/features/calendar/domain/entities/evento_entity.dart';
import 'package:toolmape/features/calendar/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/features/calendar/domain/repositories/calendario_repository.dart';
import 'package:toolmape/features/calendar/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/features/calendar/domain/value_objects/date_range.dart';
import 'package:toolmape/features/calendar/domain/value_objects/event_scope.dart';
import 'package:toolmape/app/init_dependencies.dart';

class _FakeCalRepo implements CalendarioRepository {
  @override
  Future<List<EventoEntity>> eventosEnRango({
    required DateTime start,
    required DateTime end,
  }) async {
    return [
      EventoEntity(
        id: '1',
        titulo: 'Feriado',
        descripcion: null,
        categoria: 'Feriado',
        inicio: start,
        fin: end,
        recordatorio: null,
        alcance: const EventScope(),
        fuente: null,
      ),
    ];
  }
}

class _FakeMisRepo implements MisEventosRepository {
  @override
  Future<List<MiEventoEntity>> eventosEnRango(DateRange rango) async {
    return [
      MiEventoEntity(
        id: '1',
        userId: 'u1',
        titulo: 'Propio',
        descripcion: null,
        inicio: rango.start,
        fin: rango.end,
        allDay: true,
      ),
    ];
  }

  @override
  bool get anonDisabled => false;

  @override
  Future<void> borrar(String id) async {}

  @override
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {}
}

void main() {
  test('view model fetches events and helpers work', () async {
    final container = ProviderContainer(overrides: [
      calendarioRepositoryProvider.overrideWithValue(_FakeCalRepo()),
      misEventosRepositoryProvider.overrideWithValue(_FakeMisRepo()),
    ]);

    final vm = container.read(calendarioViewModelProvider.notifier);
    final eventos = await vm.eventosDelMes(DateTime.now());
    expect(eventos, isNotEmpty);

    final propios = await vm.misEventos(vm.mesRango);
    expect(propios, isNotEmpty);

    expect(vm.mesNombrePublic(1), 'Enero');
  });
}
