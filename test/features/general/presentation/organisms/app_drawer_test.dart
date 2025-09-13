import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/general/presentation/organisms/app_drawer.dart';

void main() {
  testWidgets('tapping calculadora triggers callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: AppDrawer(
            onGoToCalculadora: () { tapped = true; },
            onGoToCalendario: () {},
          ),
        ),
      ),
    );

    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Calcular precio del oro'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });
}
