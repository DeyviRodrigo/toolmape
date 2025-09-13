import 'package:shared_preferences/shared_preferences.dart';

import 'package:toolmape/features/calculator/domain/entities/calculator_prefs_entity.dart';
import '../../data/mappers/calculator_prefs_mapper.dart';

class PreferenciasLocalDatasource {
  Future<CalculatorPrefs> load() async {
    final prefs = await SharedPreferences.getInstance();
    return CalculatorPrefsMapper.fromMap({
      'precioOro': prefs.getString('precioOro'),
      'tipoCambio': prefs.getString('tipoCambio'),
      'descuento': prefs.getString('descuento'),
      'ley': prefs.getString('ley'),
      'cantidad': prefs.getString('cantidad'),
    });
  }

  Future<void> save(CalculatorPrefs data) async {
    final prefs = await SharedPreferences.getInstance();
    final map = CalculatorPrefsMapper.toMap(data);
    await prefs.setString('precioOro', map['precioOro'] as String);
    await prefs.setString('tipoCambio', map['tipoCambio'] as String);
    await prefs.setString('descuento', map['descuento'] as String);
    await prefs.setString('ley', map['ley'] as String);
    await prefs.setString('cantidad', map['cantidad'] as String);
  }
}
