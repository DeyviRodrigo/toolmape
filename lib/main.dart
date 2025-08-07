//conectar a APIs, poner valores automáticos de precio y tipo de cambio cuando no se tengan
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/campo_numerico.dart';
import 'services/calculadora_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PrecioAuriferoApp());
}

class PrecioAuriferoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToolMAPE',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatefulWidget {
  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  double? precioPorGramo;
  double? resultado;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    _prefs = await SharedPreferences.getInstance();
    precioOroCtrl.text = _prefs.getString('precioOro') ?? '';
    tipoCambioCtrl.text = _prefs.getString('tipoCambio') ?? '';
    descuentoCtrl.text = _prefs.getString('descuento') ?? '';
    leyCtrl.text = _prefs.getString('ley') ?? '';
    cantidadCtrl.text = _prefs.getString('cantidad') ?? '';
  }

  Future<void> _guardarPreferencias() async {
    await _prefs.setString('precioOro', precioOroCtrl.text);
    await _prefs.setString('tipoCambio', tipoCambioCtrl.text);
    await _prefs.setString('descuento', descuentoCtrl.text);
    await _prefs.setString('ley', leyCtrl.text);
    await _prefs.setString('cantidad', cantidadCtrl.text);
  }

  Future<String?> _dialogoSimple({required String titulo, required String mensaje, required List<String> opciones}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: opciones.map((opt) {
          return TextButton(
            onPressed: () => Navigator.pop(context, opt),
            child: Text(opt),
          );
        }).toList(),
      ),
    );
  }

  Future<void> calcular() async {
    // Precio y cambio
    if (precioOroCtrl.text.isEmpty) precioOroCtrl.text = '3394.90';
    if (tipoCambioCtrl.text.isEmpty) tipoCambioCtrl.text = '3.56';
    // Descuento
    if (descuentoCtrl.text.isEmpty) {
      final resp = await _dialogoSimple(
        titulo: 'Descuento faltante',
        mensaje: 'No pusiste valores en descuento.',
        opciones: ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (resp == 'Utilizar predeterminado') {
        descuentoCtrl.text = '7';
      } else {
        return; // ir a ayuda descuento cuando se implemente
      }
    }
    // Ley
    if (leyCtrl.text.isEmpty) {
      final resp = await _dialogoSimple(
        titulo: 'Ley faltante',
        mensaje: 'No pusiste valores en ley.',
        opciones: ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (resp == 'Utilizar predeterminado') {
        leyCtrl.text = '93';
      } else {
        return; // ir a ayuda ley
      }
    }
    // Cantidad
    if (cantidadCtrl.text.isEmpty) cantidadCtrl.text = '1';

    final precioOro = double.parse(precioOroCtrl.text);
    final tipoCambio = double.parse(tipoCambioCtrl.text);
    final descuento = double.parse(descuentoCtrl.text);
    final ley = double.parse(leyCtrl.text);
    final cantidad = double.parse(cantidadCtrl.text);

    precioPorGramo = CalculadoraService.precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );
    resultado = CalculadoraService.calcularTotal(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
      cantidad: cantidad,
    );
    setState(() {});
    await _guardarPreferencias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calcular precio del oro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: precioOroCtrl,
                    etiqueta: 'Precio oro (USD/onza)',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.settings),
                  onSelected: (_) {},
                  itemBuilder: (_) => [],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: tipoCambioCtrl,
                    etiqueta: 'Tipo de cambio (S/ por USD)',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.settings),
                  onSelected: (_) {},
                  itemBuilder: (_) => [],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: descuentoCtrl,
                    etiqueta: 'Descuento (%)',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.help_outline),
                  onSelected: (_) {},
                  itemBuilder: (_) => [],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: leyCtrl,
                    etiqueta: 'Ley (%)',
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.help_outline),
                  onSelected: (_) {},
                  itemBuilder: (_) => [],
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: cantidadCtrl,
                    etiqueta: 'Cantidad (g)',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => AlertDialog(
                      content: Text(
                        'Coloque la cantidad de oro bruto en gramos que desea vender o calcular',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: calcular, child: Text('Calcular')),
            SizedBox(height: 24),
            if (precioPorGramo != null)
              Text(
                'Precio por gramo: S/: ${precioPorGramo!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18),
              ),
            if (resultado != null)
              Text(
                'Precio total: S/: ${resultado!.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    precioOroCtrl.dispose();
    tipoCambioCtrl.dispose();
    descuentoCtrl.dispose();
    leyCtrl.dispose();
    cantidadCtrl.dispose();
    super.dispose();
  }
}