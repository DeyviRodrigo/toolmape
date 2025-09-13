import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolmape/features/calculator/infrastructure/datasources/price_datasource.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<Map<String, dynamic>> {}

void main() {
  group('PriceDatasource', () {
    late MockSupabaseClient client;
    late dynamic builder;
    late PriceDatasource datasource;

    setUp(() {
      client = MockSupabaseClient();
      builder = MockPostgrestFilterBuilder();
      datasource = PriceDatasource(client);
    });

    test('fetchSpotGoldUsd maps values to double', () async {
      when(() => client.from(any())).thenReturn(builder);
      when(() => builder.select(any())).thenReturn(builder);
      when(() => builder.filter(any(), any(), any())).thenReturn(builder);
      when(() => builder.ilike(any(), any())).thenReturn(builder);
      when(
        () => builder.order(any(), ascending: any(named: 'ascending')),
      ).thenReturn(builder);
      when(() => builder.limit(any())).thenReturn(builder);
      when(() => builder.maybeSingle()).thenAnswer(
        (_) async =>
            {'price': '1.1', 'captured_at': '2024-01-01T00:00:00Z'}
                as Map<String, dynamic>,
      );

      final res = await datasource.fetchSpotGoldUsd();
      expect(res.data['price'], 1.1);
      expect(res.capturedAt, DateTime.parse('2024-01-01T00:00:00Z'));
    });

    test('fetchLatestGold maps values to double', () async {
      when(() => client.from(any())).thenReturn(builder);
      when(() => builder.select(any())).thenReturn(builder);
      when(
        () => builder.order(any(), ascending: any(named: 'ascending')),
      ).thenReturn(builder);
      when(() => builder.limit(any())).thenReturn(builder);
      when(() => builder.maybeSingle()).thenAnswer(
        (_) async =>
            {'gold_price': 2, 'captured_at': '2024-01-01T00:00:00Z'}
                as Map<String, dynamic>,
      );

      final res = await datasource.fetchLatestGold();
      expect(res.data['gold_price'], 2.0);
      expect(res.capturedAt, DateTime.parse('2024-01-01T00:00:00Z'));
    });

    test('fetchDailySummary maps values to double', () async {
      when(() => client.from(any())).thenReturn(builder);
      when(() => builder.select(any())).thenReturn(builder);
      when(() => builder.eq(any(), any())).thenReturn(builder);
      when(() => builder.maybeSingle()).thenAnswer(
        (_) async =>
            {
                  'avg_gold_latest_price': '3.3',
                  'lbma_gold_am': 4,
                  'lbma_gold_pm': '5',
                  'avg_gold_spot_price': '6',
                  'avg_gold_spot_ask': 7,
                  'avg_gold_spot_bid': 8,
                  'avg_gold_spot_high': 9,
                  'avg_gold_spot_low': 10,
                }
                as Map<String, dynamic>,
      );

      final res = await datasource.fetchDailySummary(DateTime(2024, 1, 1));
      expect(res.latest['gold_price'], 3.3);
      expect(res.spot['ask'], 7.0);
    });
  });
}
