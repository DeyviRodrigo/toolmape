import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toolmape/data/price_datasource.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<Map<String, dynamic>> {}

void main() {
  group('PriceDatasource', () {
    late MockSupabaseClient client;
    late MockPostgrestFilterBuilder builder;
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
      when(() => builder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(builder);
      when(() => builder.limit(any())).thenReturn(builder);
      when(() => builder.maybeSingle())
          .thenAnswer((_) async => {'price': '1.1'});

      final res = await datasource.fetchSpotGoldUsd();
      expect(res['price'], 1.1);
    });

    test('fetchLatestGold maps values to double', () async {
      when(() => client.from(any())).thenReturn(builder);
      when(() => builder.select(any())).thenReturn(builder);
      when(() => builder.order(any(), ascending: any(named: 'ascending')))
          .thenReturn(builder);
      when(() => builder.limit(any())).thenReturn(builder);
      when(() => builder.maybeSingle())
          .thenAnswer((_) async => {'gold_price': 2});

      final res = await datasource.fetchLatestGold();
      expect(res['gold_price'], 2.0);
    });
  });
}
