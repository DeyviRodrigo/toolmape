import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calendar/data/dtos/evento_dto.dart';
import 'package:toolmape/features/calendar/data/mappers/evento_mapper.dart';

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
}
