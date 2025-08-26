import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/presentation/controllers/calendario_controller.dart';
import 'package:toolmape/presentation/screens/calendario_screen.dart';

void main() {
  testWidgets('shows event count and button', (tester) async {
    final controller = CalendarioController(
      getEventosMes: (d) async => [],
      getMisEventos: (r) async => [],
      crearEvento: ({required String titulo, String? descripcion, required DateTime inicio, DateTime? fin, bool allDay = false}) async {},
    );

    await tester.pumpWidget(MaterialApp(home: CalendarioScreen(controller: controller)));
    await tester.pump(); // resolve future

    expect(find.text('Eventos este mes: 0'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
