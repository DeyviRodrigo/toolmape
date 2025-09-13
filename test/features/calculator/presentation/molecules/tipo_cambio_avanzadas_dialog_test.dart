import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toolmape/features/calculator/infrastructure/datasources/exchange_rate_datasource.dart';
import 'package:toolmape/features/calculator/presentation/molecules/tipo_cambio_avanzadas_dialog.dart';

class MockExchangeRateDatasource extends Mock
    implements ExchangeRateDatasource {}

void main() {
  testWidgets('dialog shows data', (tester) async {
    final ds = MockExchangeRateDatasource();
    when(() => ds.fetchLatest()).thenAnswer(
      (_) async => (value: 3.5, capturedAt: DateTime(2024)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () =>
                  showTipoCambioAvanzadasDialog(context, datasource: ds),
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('3.50'), findsOneWidget);
  });

  testWidgets('dialog handles empty data', (tester) async {
    final ds = MockExchangeRateDatasource();
    when(() => ds.fetchLatest()).thenAnswer(
      (_) async => (value: null, capturedAt: null),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () =>
                  showTipoCambioAvanzadasDialog(context, datasource: ds),
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('-'), findsOneWidget);
  });
}
