import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toolmape/features/calendario/calendario_view_model.dart';

void main() {
  test('mesNombre returns Spanish month names', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final vm = container.read(calendarioViewModelProvider.notifier);

    expect(vm.mesNombre(1), 'Enero');
    expect(vm.mesNombre(6), 'Junio');
    expect(vm.mesNombre(12), 'Diciembre');
  });
}
