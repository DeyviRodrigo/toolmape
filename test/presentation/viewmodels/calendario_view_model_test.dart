import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/presentation/viewmodels/calendario_view_model.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/domain/repositories/calendario_repository.dart';
import 'package:toolmape/domain/repositories/mis_eventos_repository.dart';
import 'package:toolmape/domain/value_objects/date_range_entity.dart';
import 'package:toolmape/init_dependencies.dart';

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
        alcance: const {},
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
