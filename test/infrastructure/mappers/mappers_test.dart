import 'package:test/test.dart';
import 'package:toolmape/domain/entities/evento_entity.dart';
import 'package:toolmape/domain/entities/mi_evento_entity.dart';
import 'package:toolmape/infrastructure/dto/evento_dto.dart';
import 'package:toolmape/infrastructure/dto/mi_evento_dto.dart';
import 'package:toolmape/infrastructure/mappers/evento_mapper.dart';
import 'package:toolmape/infrastructure/mappers/mi_evento_mapper.dart';

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
}
