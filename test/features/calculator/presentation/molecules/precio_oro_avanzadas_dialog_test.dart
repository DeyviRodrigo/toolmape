import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toolmape/features/calculator/data/price_datasource.dart';
import 'package:toolmape/features/calculator/presentation/molecules/precio_oro_avanzadas_dialog.dart';

class MockPriceDatasource extends Mock implements PriceDatasource {}

void main() {
  testWidgets('dialog shows data', (tester) async {
    final ds = MockPriceDatasource();
    when(() => ds.fetchLatestGold()).thenAnswer(
      (_) async => (data: {'gold_price': 1.0}, capturedAt: DateTime(2024)),
    );
    when(() => ds.fetchSpotGoldUsd()).thenAnswer(
      (_) async => (data: {'price': 2.0}, capturedAt: DateTime(2024)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () =>
                  showPrecioOroAvanzadasDialog(context, datasource: ds),
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Precio'), findsOneWidget);
  });

  testWidgets('dialog handles empty data', (tester) async {
    final ds = MockPriceDatasource();
    when(
      () => ds.fetchLatestGold(),
    ).thenAnswer((_) async => (data: <String, double?>{}, capturedAt: null));
    when(
      () => ds.fetchSpotGoldUsd(),
    ).thenAnswer((_) async => (data: <String, double?>{}, capturedAt: null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () =>
                  showPrecioOroAvanzadasDialog(context, datasource: ds),
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('-'), findsWidgets);
  });
}
