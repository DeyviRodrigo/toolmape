import '../../domain/entities/calculator_prefs_entity.dart';

/// Mapper to convert [CalculatorPrefs] to and from raw data structures.
class CalculatorPrefsMapper {
  /// Creates a [CalculatorPrefs] from a JSON-like [Map].
  static CalculatorPrefs fromMap(Map<String, dynamic> map) => CalculatorPrefs(
        precioOro: map['precioOro'] as String? ?? '',
        tipoCambio: map['tipoCambio'] as String? ?? '',
        descuento: map['descuento'] as String? ?? '',
        ley: map['ley'] as String? ?? '',
        cantidad: map['cantidad'] as String? ?? '',
      );

  /// Converts a [CalculatorPrefs] into a JSON-like [Map].
  static Map<String, dynamic> toMap(CalculatorPrefs prefs) => {
        'precioOro': prefs.precioOro,
        'tipoCambio': prefs.tipoCambio,
        'descuento': prefs.descuento,
        'ley': prefs.ley,
        'cantidad': prefs.cantidad,
      };
}
