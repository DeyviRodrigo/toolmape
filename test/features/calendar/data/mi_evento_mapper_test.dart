import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calendar/data/dtos/mi_evento_dto.dart';
import 'package:toolmape/features/calendar/data/mappers/mi_evento_mapper.dart';

void main() {
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
