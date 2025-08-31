import '../entities/calculator_prefs_entity.dart';

typedef SetString = Future<void> Function(String key, String value);

class SavePrefs {
  final SetString setString;
  SavePrefs({required this.setString});

  Future<void> call(CalculatorPrefs prefs) async {
    await setString('precioOro', prefs.precioOro);
    await setString('tipoCambio', prefs.tipoCambio);
    await setString('descuento', prefs.descuento);
    await setString('ley', prefs.ley);
    await setString('cantidad', prefs.cantidad);
  }
}
