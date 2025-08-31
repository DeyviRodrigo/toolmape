import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/calculator_prefs_entity.dart';

class PreferenciasLocalDatasource {
  Future<CalculatorPrefs> load() async {
    final prefs = await SharedPreferences.getInstance();
    return CalculatorPrefs(
      precioOro: prefs.getString('precioOro') ?? '',
      tipoCambio: prefs.getString('tipoCambio') ?? '',
      descuento: prefs.getString('descuento') ?? '',
      ley: prefs.getString('ley') ?? '',
      cantidad: prefs.getString('cantidad') ?? '',
    );
  }

  Future<void> save(CalculatorPrefs data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('precioOro', data.precioOro);
    await prefs.setString('tipoCambio', data.tipoCambio);
    await prefs.setString('descuento', data.descuento);
    await prefs.setString('ley', data.ley);
    await prefs.setString('cantidad', data.cantidad);
  }
}
