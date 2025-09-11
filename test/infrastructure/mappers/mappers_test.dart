import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/domain/entities/calculator_prefs_entity.dart';
import 'package:toolmape/infrastructure/dto/evento_dto.dart';
import 'package:toolmape/infrastructure/dto/mi_evento_dto.dart';
import 'package:toolmape/infrastructure/mappers/evento_mapper.dart';
import 'package:toolmape/infrastructure/mappers/mi_evento_mapper.dart';
import 'package:toolmape/infrastructure/mappers/calculator_prefs_mapper.dart';

void main() {
  test('EventoMapper maps between dto and entity', () {
    final json = {
      'id': '1',
      'titulo': 't',
      'descripcion': null,
      'categoria': null,
      'inicio': '2024-01-01T00:00:00.000',
      'fin': '2024-01-02T00:00:00.000',
      'recordatorio': null,
      'alcance': <String, dynamic>{},
      'fuente': null,
    };
    final dto = EventoDto.fromJson(json);
    final entity = EventoMapper.fromDto(dto);
    expect(entity.id, '1');
    final back = EventoMapper.toDto(entity);
    expect(back.toJson(), json);
  });

  test('MiEventoMapper maps between dto and entity', () {
    final json = {
      'id': '1',
      'user_id': 'u',
      'titulo': 'p',
      'descripcion': null,
      'inicio': '2024-01-01T00:00:00.000',
      'fin': null,
      'all_day': false,
    };
    final dto = MiEventoDto.fromJson(json);
    final entity = MiEventoMapper.fromDto(dto);
    expect(entity.userId, 'u');
    final back = MiEventoMapper.toDto(entity);
    expect(back.toJson(), json);
  });

  test('CalculatorPrefsMapper maps between map and entity', () {
    final map = {
      'precioOro': '1',
      'tipoCambio': '2',
      'descuento': '3',
      'ley': '4',
      'cantidad': '5',
    };
    final entity = CalculatorPrefsMapper.fromMap(map);
    expect(entity.precioOro, '1');
    final back = CalculatorPrefsMapper.toMap(entity);
    expect(back, map);
  });
}
