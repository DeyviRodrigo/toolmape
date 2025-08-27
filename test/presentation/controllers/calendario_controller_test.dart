import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/presentation/controllers/calendario_controller.dart';

class _FakeGetEventosMes {
  DateTime? calledWith;
  Future<List<EventoEntity>> call(DateTime d) async {
    calledWith = d;
    return [];
  }
}

class _FakeGetMisEventos {
  DateTimeRange? calledWith;
  Future<List<MiEventoEntity>> call(DateTimeRange r) async {
    calledWith = r;
    return [];
  }
}

class _FakeCrearEvento {
  String? titulo;
  Future<void> call({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {
    this.titulo = titulo;
  }
}

void main() {
  test('controller delegates to use cases', () async {
    final g = _FakeGetEventosMes();
    final m = _FakeGetMisEventos();
    final c = _FakeCrearEvento();

    final controller = CalendarioController(
      getEventosMes: g.call,
      getMisEventos: m.call,
      crearEvento: c.call,
    );

    final mes = DateTime(2024, 1, 1);
    await controller.eventosDelMes(mes);
    expect(g.calledWith, mes);

    final range = DateTimeRange(start: DateTime(2024, 1), end: DateTime(2024, 2));
    await controller.misEventos(range);
    expect(m.calledWith, range);

    await controller.crearEvento(titulo: 'test', inicio: DateTime(2024, 1, 1));
    expect(c.titulo, 'test');
  });
}
