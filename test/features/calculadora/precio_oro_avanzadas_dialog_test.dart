import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toolmape/data/price_datasource.dart';
import 'package:toolmape/features/calculadora/widgets/precio_oro_avanzadas_dialog.dart';

class MockPriceDatasource extends Mock implements PriceDatasource {}

void main() {
  testWidgets('dialog shows data', (tester) async {
    final ds = MockPriceDatasource();
    when(() => ds.fetchLatestGold())
        .thenAnswer((_) async => {'gold_price': 1});
    when(() => ds.fetchSpotGoldUsd())
        .thenAnswer((_) async => {'price': 2});

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => showPrecioOroAvanzadasDialog(context, datasource: ds),
          child: const Text('open'),
        );
      }),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Gold'), findsOneWidget);
    expect(find.text('Precio'), findsOneWidget);
  });

  testWidgets('dialog handles empty data', (tester) async {
    final ds = MockPriceDatasource();
    when(() => ds.fetchLatestGold()).thenAnswer((_) async => {});
    when(() => ds.fetchSpotGoldUsd()).thenAnswer((_) async => {});

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => showPrecioOroAvanzadasDialog(context, datasource: ds),
          child: const Text('open'),
        );
      }),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('-'), findsWidgets);
  });
}
