import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/design_system/atoms/numeric_field.dart';

void main() {
  testWidgets('NumericField updates controller with input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumericField(controller: controller, etiqueta: 'Cantidad'),
        ),
      ),
    );

    expect(find.text('Cantidad'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123');
    expect(controller.text, '123');
  });
}
