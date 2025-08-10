import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/main.dart';

void main() {
  testWidgets('Pantalla calculadora se muestra por defecto', (WidgetTester tester) async {
    // Carga la app
    await tester.pumpWidget(const ToolMAPEApp());

    // Primero debe verse el Splash
    expect(find.byType(SplashScreen), findsOneWidget);

    // Avanza el tiempo para que el Splash navegue a la calculadora
    await tester.pump(const Duration(seconds: 3));

    // Ahora debe verse la calculadora
    expect(find.text('Calcular precio del oro'), findsOneWidget);
  });
}
