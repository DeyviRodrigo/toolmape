import 'dart:convert';
import 'package:http/http.dart' as http;

class CalculadoraService {
  static const double _gramosPorOnza = 31.1034768;
  static const String _apiKeyMetals = 'TU_API_KEY_METALS';

  static Future<double> obtenerPrecioOroApi() async {
    final url = Uri.parse(
        'https://metals-api.com/api/latest?access_key=\$_apiKeyMetals&base=USD&symbols=XAU'
    );
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return (data['rates']['XAU'] as num).toDouble();
    }
    throw Exception('Error al obtener precio de oro: \${resp.statusCode}');
  }

  static Future<double> obtenerTipoCambioApi() async {
    final url = Uri.parse('https://api.exchangerate.host/latest?base=USD&symbols=PEN');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return (data['rates']['PEN'] as num).toDouble();
    }
    throw Exception('Error al obtener tipo de cambio: \${resp.statusCode}');
  }

  static double precioPorGramoEnSoles({
    required double precioOro,
    required double tipoCambio,
    required double descuento,
    required double ley,
  }) {
    final precioGramoUsd = precioOro / _gramosPorOnza;
    final ajustado = precioGramoUsd * (ley / 100) * (1 - descuento / 100);
    return ajustado * tipoCambio;
  }

  static double calcularTotal({
    required double precioOro,
    required double tipoCambio,
    required double descuento,
    required double ley,
    required double cantidad,
  }) {
    final precioUnitario = precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    return precioUnitario * cantidad;
  }
}