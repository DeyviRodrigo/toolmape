import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource contract for personal events.
abstract class MisEventosDatasource {
  bool get anonDisabled;

  Future<List<Map<String, dynamic>>> eventosEnRango(
      DateTime start, DateTime end);

  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  });

  Future<void> borrar(String id);
}

/// Supabase implementation handling auth and CRUD operations.
class MisEventosSupabaseDatasource implements MisEventosDatasource {
  MisEventosSupabaseDatasource(this._client);
  final SupabaseClient _client;

  bool _anonDisabled = false;

  @override
  bool get anonDisabled => _anonDisabled;

  Future<void> _ensureAnonAuth() async {
    if (_anonDisabled) return;

    var user = _client.auth.currentUser;
    if (user != null) return;

    try {
      final res = await _client.auth.signInAnonymously();
      user = res.user;
      if (user == null) {
        _anonDisabled = true;
      }
    } on AuthApiException catch (e) {
      final code = e.statusCode?.toString();
      final msg = (e.message).toLowerCase();
      if (code == '422' || msg.contains('anonymous') || msg.contains('disabled')) {
        _anonDisabled = true;
        return;
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> eventosEnRango(
      DateTime start, DateTime end) async {
    await _ensureAnonAuth();
    if (_anonDisabled || _client.auth.currentUser == null) return [];
    try {
      final uid = _client.auth.currentUser!.id;
      final res = await _client
          .from('calendario_eventos_usuario')
          .select('*')
          .eq('user_id', uid)
          .gte('inicio', start.toUtc().toIso8601String())
          .lte('inicio', end.toUtc().toIso8601String())
          .order('inicio');

      return (res as List).cast<Map<String, dynamic>>();
    } on AuthApiException catch (e) {
      final code = e.statusCode?.toString();
      final msg = (e.message).toLowerCase();
      if (code == '422' || msg.contains('anonymous') || msg.contains('disabled')) {
        _anonDisabled = true;
        return [];
      }
      rethrow;
    }
  }

  @override
  Future<void> crear({
    required String titulo,
    String? descripcion,
    required DateTime inicio,
    DateTime? fin,
    bool allDay = false,
  }) async {
    await _ensureAnonAuth();
    if (_anonDisabled || _client.auth.currentUser == null) {
      throw StateError('EVENTS_AUTH_DISABLED');
    }
    await _client.from('calendario_eventos_usuario').insert({
      'user_id': _client.auth.currentUser!.id,
      'titulo': titulo,
      'descripcion': descripcion,
      'inicio': inicio.toUtc().toIso8601String(),
      'fin': fin?.toUtc().toIso8601String(),
      'all_day': allDay,
    });
  }

  @override
  Future<void> borrar(String id) async {
    await _ensureAnonAuth();
    if (_anonDisabled || _client.auth.currentUser == null) {
      throw StateError('EVENTS_AUTH_DISABLED');
    }
    await _client
        .from('calendario_eventos_usuario')
        .delete()
        .eq('id', id);
  }
}
