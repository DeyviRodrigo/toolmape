import '../entities/calculator_prefs_entity.dart';

typedef GetString = Future<String?> Function(String key);

class LoadPrefs {
  final GetString getString;
  LoadPrefs({required this.getString});

  Future<CalculatorPrefs> call() async {
    return CalculatorPrefs(
      precioOro: await getString('precioOro') ?? '',
      tipoCambio: await getString('tipoCambio') ?? '',
      descuento: await getString('descuento') ?? '',
      ley: await getString('ley') ?? '',
      cantidad: await getString('cantidad') ?? '',
    );
  }
}
