import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/general/presentation/molecules/app_drawer_item.dart';

void main() {
  testWidgets('AppDrawerItem renders and reacts to tap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDrawerItem(
            icon: Icons.calculate_outlined,
            title: 'Calcular precio del oro',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Calcular precio del oro'), findsOneWidget);
    expect(find.byIcon(Icons.calculate_outlined), findsOneWidget);

    await tester.tap(find.byType(AppDrawerItem));
    expect(tapped, isTrue);
  });
}
