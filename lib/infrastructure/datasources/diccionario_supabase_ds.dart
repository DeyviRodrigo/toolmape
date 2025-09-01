import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DiccionarioDatasource {
  Future<List<Map<String, dynamic>>> unidades();
  Future<List<Map<String, dynamic>>> monedas();
  Future<List<Map<String, dynamic>>> metales();
}

class DiccionarioSupabaseDatasource implements DiccionarioDatasource {
  DiccionarioSupabaseDatasource(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> unidades() async {
    final res = await _client.from('dim_unit').select('*').order('code');
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> monedas() async {
    final res = await _client.from('dim_currency').select('*').order('code');
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Future<List<Map<String, dynamic>>> metales() async {
    final res = await _client.from('dim_metal').select('*').order('code');
    return (res as List).cast<Map<String, dynamic>>();
  }
}
