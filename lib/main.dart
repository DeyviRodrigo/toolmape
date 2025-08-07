import 'package:flutter/material.dart';
import 'widgets/campo_numerico.dart';
import 'services/calculadora_service.dart';

void main() => runApp(PrecioAuriferoApp());

class PrecioAuriferoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Básica Oro',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: PantallaCalculadoraBasica(),
    );
  }
}

class PantallaCalculadoraBasica extends StatefulWidget {
  @override
  _PantallaCalculadoraBasicaState createState() => _PantallaCalculadoraBasicaState();
}

class _PantallaCalculadoraBasicaState extends State<PantallaCalculadoraBasica> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  double? precioPorGramo;
  double? resultado;

  void calcular() {
    final precioOro = double.tryParse(precioOroCtrl.text) ?? 0;
    final tipoCambio = double.tryParse(tipoCambioCtrl.text) ?? 1;
    final descuento = double.tryParse(descuentoCtrl.text) ?? 0;
    final ley = double.tryParse(leyCtrl.text) ?? 100;
    final cantidad = double.tryParse(cantidadCtrl.text) ?? 0;

    // Precio por gramo en soles
    precioPorGramo = CalculadoraService.precioPorGramoEnSoles(
      precioOro: precioOro,
      tipoCambio: tipoCambio,
      descuento: descuento,
      ley: ley,
    );

    // Total en soles
    resultado = precioPorGramo! * cantidad;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calculadora Básica Oro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampoNumerico(controller: precioOroCtrl, etiqueta: 'Precio oro (USD/onza)'),
              SizedBox(height: 8),
              CampoNumerico(controller: tipoCambioCtrl, etiqueta: 'Tipo de cambio (S/ por USD)'),
              SizedBox(height: 8),
              CampoNumerico(controller: descuentoCtrl, etiqueta: 'Descuento (%)'),
              SizedBox(height: 8),
              CampoNumerico(controller: leyCtrl, etiqueta: 'Ley (%)'),
              SizedBox(height: 8),
              CampoNumerico(controller: cantidadCtrl, etiqueta: 'Cantidad (g)'),
              SizedBox(height: 16),
              ElevatedButton(onPressed: calcular, child: Text('Calcular')),
              SizedBox(height: 24),

              if (precioPorGramo != null) ...[
                Text(
                  'Precio por gramo: S/: ${precioPorGramo!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
              ],
              if (resultado != null)
                Text(
                  'Precio total: S/: ${resultado!.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
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