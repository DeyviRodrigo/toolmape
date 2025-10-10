import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';

/// Exception thrown when Supabase operations for volquetes fail.
class VolquetesDatasourceException implements Exception {
  VolquetesDatasourceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'VolquetesDatasourceException: ' '$message';
}

/// Datasource in charge of synchronising volquetes with Supabase.
class VolquetesSupabaseDatasource {
  VolquetesSupabaseDatasource(this._client);

  final SupabaseClient _client;

  static const _volquetesTable = 'control_tiempos_volquetes';
  static const _eventosTable = 'control_tiempos_eventos';

  Future<List<Volquete>> fetchVolquetes() async {
    try {
      final response = await _client
          .from(_volquetesTable)
          .select(
            'id,codigo,placa,operador,destino,fecha,estado,tipo,equipo,documento,notas,'
            'eventos:$_eventosTable(id,titulo,descripcion,fecha)',
          )
          .order('fecha', ascending: false);

      final List<dynamic> rows = response as List<dynamic>;
      return rows
          .map((row) => _mapVolqueteFromRow(row as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw VolquetesDatasourceException(
        'No se pudieron obtener los volquetes desde Supabase.',
        error,
      );
    }
  }

  Future<Volquete> upsertVolquete(Volquete volquete) async {
    try {
      final payload = _mapVolqueteToRow(volquete);

      final upserted = await _client
          .from(_volquetesTable)
          .upsert(payload, onConflict: 'id')
          .select(
            'id,codigo,placa,operador,destino,fecha,estado,tipo,equipo,documento,notas,'
            'eventos:$_eventosTable(id,titulo,descripcion,fecha)',
          )
          .maybeSingle();

      final dynamic rawId = upserted?['id'] ?? payload['id'];
      final String? maybeId = rawId == null ? null : rawId.toString().trim();

      if ((maybeId == null || maybeId.isEmpty) && _isTemporaryId(volquete.id)) {
        throw VolquetesDatasourceException(
          'Supabase no devolvió un identificador para el nuevo volquete.',
        );
      }

      final String volqueteId = (maybeId == null || maybeId.isEmpty)
          ? volquete.id
          : maybeId;

      // Replace events with the provided list to keep them in sync.
      await _client
          .from(_eventosTable)
          .delete()
          .eq('volquete_id', volqueteId);

      if (volquete.eventos.isNotEmpty) {
        final eventosPayload = volquete.eventos.map((evento) {
          return {
            'volquete_id': volqueteId,
            'titulo': evento.titulo,
            'descripcion': evento.descripcion,
            'fecha': evento.fecha.toIso8601String(),
          };
        }).toList();

        await _client.from(_eventosTable).insert(eventosPayload);
      }

      final refreshed = await _client
          .from(_volquetesTable)
          .select(
            'id,codigo,placa,operador,destino,fecha,estado,tipo,equipo,documento,notas,'
            'eventos:$_eventosTable(id,titulo,descripcion,fecha)',
          )
          .eq('id', volqueteId)
          .maybeSingle();

      if (refreshed == null) {
        throw VolquetesDatasourceException(
          'Supabase no devolvió el registro recién guardado.',
        );
      }

      return _mapVolqueteFromRow(Map<String, dynamic>.from(refreshed));
    } catch (error) {
      throw VolquetesDatasourceException(
        'No se pudo guardar el volquete en Supabase.',
        error,
      );
    }
  }

  Future<void> deleteVolquete(String id) async {
    try {
      await _client.from(_eventosTable).delete().eq('volquete_id', id);
      await _client.from(_volquetesTable).delete().eq('id', id);
    } catch (error) {
      throw VolquetesDatasourceException(
        'No se pudo eliminar el volquete en Supabase.',
        error,
      );
    }
  }

  Volquete _mapVolqueteFromRow(Map<String, dynamic> row) {
    final estado = _parseEstado(row['estado'] as String?);
    final tipo = _parseTipo(row['tipo'] as String?);
    final equipo = _parseEquipo(row['equipo'] as String?);

    final eventosData = row['eventos'] as List<dynamic>?;
    final eventos = (eventosData ?? [])
        .map((eventRow) => _mapEvento(eventRow as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    return Volquete(
      id: row['id'].toString(),
      codigo: (row['codigo'] as String?) ?? '',
      placa: (row['placa'] as String?) ?? '',
      operador: (row['operador'] as String?) ?? '',
      destino: (row['destino'] as String?) ?? '',
      fecha: _parseDate(row['fecha']) ?? DateTime.now(),
      estado: estado,
      tipo: tipo,
      equipo: equipo,
      documento: row['documento'] as String?,
      notas: row['notas'] as String?,
      eventos: eventos,
    );
  }

  Map<String, dynamic> _mapVolqueteToRow(Volquete volquete) {
    final map = <String, dynamic>{
      'codigo': volquete.codigo,
      'placa': volquete.placa,
      'operador': volquete.operador,
      'destino': volquete.destino,
      'fecha': volquete.fecha.toIso8601String(),
      'estado': volquete.estado.name,
      'tipo': volquete.tipo.name,
      'equipo': volquete.equipo.name,
      'documento': volquete.documento,
      'notas': volquete.notas,
    };

    if (!_isTemporaryId(volquete.id)) {
      map['id'] = volquete.id;
    }

    return map;
  }

  VolqueteEvento _mapEvento(Map<String, dynamic> row) {
    return VolqueteEvento(
      titulo: (row['titulo'] as String?) ?? '',
      descripcion: (row['descripcion'] as String?) ?? '',
      fecha: _parseDate(row['fecha']) ?? DateTime.now(),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  VolqueteEstado _parseEstado(String? value) {
    switch (value) {
      case 'completo':
        return VolqueteEstado.completo;
      case 'pausado':
        return VolqueteEstado.pausado;
      case 'enProceso':
      case 'en_proceso':
        return VolqueteEstado.enProceso;
      default:
        return VolqueteEstado.enProceso;
    }
  }

  VolqueteTipo _parseTipo(String? value) {
    switch (value) {
      case 'descarga':
        return VolqueteTipo.descarga;
      case 'carga':
        return VolqueteTipo.carga;
      default:
        return VolqueteTipo.carga;
    }
  }

  VolqueteEquipo _parseEquipo(String? value) {
    switch (value) {
      case 'excavadora':
        return VolqueteEquipo.excavadora;
      case 'cargador':
        return VolqueteEquipo.cargador;
      default:
        return VolqueteEquipo.cargador;
    }
  }

  bool _isTemporaryId(String id) => id.startsWith('local-');
}
