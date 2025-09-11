import 'package:flutter_test/flutter_test.dart';
import 'package:toolmape/features/calculator/core/utils/number_parsing.dart';

void main() {
  test('parseDouble parses commas', () {
    expect(parseDouble('1,5'), 1.5);
    expect(parseDouble('2.5'), 2.5);
    expect(parseDouble('abc'), isNull);
  });
}
