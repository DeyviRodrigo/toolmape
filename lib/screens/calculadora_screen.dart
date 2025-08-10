import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/campo_numerico.dart';
import '../services/calculadora_service.dart';
import '../config/calculadora_options.dart'; // <-- usa tu archivo renombrado
import '../utils/formatters.dart';
import '../utils/dialogs.dart';

class ScreenCalculadora extends StatefulWidget {
  const ScreenCalculadora({super.key});
  @override
  State<ScreenCalculadora> createState() => _ScreenCalculadoraState();
}

class _ScreenCalculadoraState extends State<ScreenCalculadora> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  double? precioPorGramo;
  double? resultado;
  late SharedPreferences _prefs;

  static const Offset _menuOffsetUp = Offset(0, -36);

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
    setState(() {});
  }

  Future<void> _guardarPreferencias() async {
    await _prefs.setString('precioOro', precioOroCtrl.text);
    await _prefs.setString('tipoCambio', tipoCambioCtrl.text);
    await _prefs.setString('descuento', descuentoCtrl.text);
    await _prefs.setString('ley', leyCtrl.text);
    await _prefs.setString('cantidad', cantidadCtrl.text);
  }

  // Builder genérico de menús (usa MenuOption<T> de calculadora_options.dart)
  PopupMenuButton<T> buildMenu<T>({
    required IconData icon,
    required List<MenuOption<T>> options,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      icon: Icon(icon),
      offset: _menuOffsetUp,
      itemBuilder: (_) => options
          .map(
            (o) => PopupMenuItem<T>(
          value: o.value,
          child: Row(
            children: [
              Icon(o.icon, size: 20),
              const SizedBox(width: 10),
              Text(o.label),
            ],
          ),
        ),
      )
          .toList(),
      onSelected: onSelected,
    );
  }

  // Acciones de menús
  void _onGeneral(GeneralAction a, TextEditingController target) {
    switch (a) {
      case GeneralAction.actualizar:
      // TODO: reemplazar por API/base de datos
        if (target == precioOroCtrl) precioOroCtrl.text = '3394.90';
        if (target == tipoCambioCtrl) tipoCambioCtrl.text = '3.56';
        setState(() {});
        break;
      case GeneralAction.avanzadas:
      // TODO: navegar a pantalla avanzada
        break;
      case GeneralAction.personalizados:
      // TODO: abrir modal de edición manual
        break;
    }
  }

  void _onDescuento(DescuentoAction a) async {
    switch (a) {
      case DescuentoAction.ayuda:
      case DescuentoAction.desdePrecio:
        await _dialogoCalcularDescuentoConLey(); // ← nuevo flujo con LEY
        break;
      case DescuentoAction.predeterminado:
        descuentoCtrl.text = '7';
        setState(() {});
        break;
    }
  }

  void _onLey(LeyAction a) {
    switch (a) {
      case LeyAction.ayuda:
      // TODO: navegar a flujo de ayuda de ley
        break;
      case LeyAction.predeterminado:
        leyCtrl.text = '93';
        setState(() {});
        break;
    }
  }

  // Precio base en S/ por gramo sin descuento (considera ley y tipo de cambio)
  double _baseSolesPorGramo({
    required double precioOroUsdOnza,
    required double tipoCambio,
    required double leyPct,
  }) {
    const gramosPorOnza = 31.1034768;
    final usdPorGramo = precioOroUsdOnza / gramosPorOnza;
    final usdAjustado = usdPorGramo * (leyPct / 100.0);
    return usdAjustado * tipoCambio;
  }

  Future<void> calcular() async {
    // Defaults automáticos
    if (precioOroCtrl.text.trim().isEmpty) precioOroCtrl.text = '3394.90';
    if (tipoCambioCtrl.text.trim().isEmpty) tipoCambioCtrl.text = '3.56';

    // Mensajes si faltan
    if (descuentoCtrl.text.trim().isEmpty) {
      final sel = await choiceDialog(
        context: context,
        title: 'Descuento faltante',
        message: 'No pusiste valores en descuento.',
        options: const ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (sel == 'Utilizar predeterminado') {
        descuentoCtrl.text = '7';
      } else {
        return;
      }
    }
    if (leyCtrl.text.trim().isEmpty) {
      final sel = await choiceDialog(
        context: context,
        title: 'Ley faltante',
        message: 'No pusiste valores en ley.',
        options: const ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (sel == 'Utilizar predeterminado') {
        leyCtrl.text = '93';
      } else {
        return;
      }
    }
    if (cantidadCtrl.text.trim().isEmpty) cantidadCtrl.text = '1';

    double _p(String s) => double.parse(s.replaceAll(',', '.'));

    final precioOro = _p(precioOroCtrl.text);
    final tipoCambio = _p(tipoCambioCtrl.text);
    final descuento = _p(descuentoCtrl.text);
    final ley = _p(leyCtrl.text);
    final cantidad = _p(cantidadCtrl.text);

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

  Future<void> _dialogoCalcularDescuentoConLey() async {
    // Asegura defaults para poder calcular
    if (precioOroCtrl.text.trim().isEmpty) precioOroCtrl.text = '3394.90';
    if (tipoCambioCtrl.text.trim().isEmpty) tipoCambioCtrl.text = '3.56';

    while (true) {
      final precioOfrecidoCtrl = TextEditingController();
      final leyInputCtrl = TextEditingController(
        text: leyCtrl.text.isNotEmpty ? leyCtrl.text : '93',
      );

      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Calcular descuento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Precio ofrecido por gramo (S/):'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: precioOfrecidoCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 300.00',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ley (%)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: leyInputCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ej: 93',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<LeyAction>(
                        icon: const Icon(Icons.help_outline),
                        offset: const Offset(0, -12),
                        itemBuilder: (_) => leyMenuOptions.map((o) =>
                            PopupMenuItem<LeyAction>(
                              value: o.value,
                              child: Row(children: [
                                Icon(o.icon, size: 18),
                                const SizedBox(width: 8),
                                Text(o.label),
                              ]),
                            ),
                        ).toList(),
                        onSelected: (act) {
                          switch (act) {
                            case LeyAction.ayuda:
                            // TODO: Navegar a flujo de ayuda de ley
                              break;
                            case LeyAction.predeterminado:
                              leyInputCtrl.text = '93';
                              setLocalState(() {});
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Calcular')),
              ],
            );
          },
        ),
      );

      if (ok != true) return;

      // Parseo y cálculo
      final ofrecido = double.tryParse(precioOfrecidoCtrl.text.replaceAll(',', '.'));
      final leyUsada = double.tryParse(leyInputCtrl.text.replaceAll(',', '.')) ?? 93.0;
      if (ofrecido == null || ofrecido <= 0) return;

      final precioOro = double.parse(precioOroCtrl.text.replaceAll(',', '.'));
      final tc = double.parse(tipoCambioCtrl.text.replaceAll(',', '.'));

      final base = _baseSolesPorGramo(
        precioOroUsdOnza: precioOro,
        tipoCambio: tc,
        leyPct: leyUsada,
      );

      double d = 100 * (1 - (ofrecido / base));
      if (d < 0) d = 0;
      if (d > 100) d = 100;

      // Mostrar resultado y decidir
      final next = await _dialogoResultadoDescuento(d);
      if (next == 'recalcular') {
        // vuelve al while y reabre el formulario
        continue;
      } else {
        // continuar: aplica valores al formulario
        descuentoCtrl.text = d.toStringAsFixed(2);
        leyCtrl.text = leyUsada.toStringAsFixed(2);
        setState(() {});
        return;
      }
    }
  }

  Future<String?> _dialogoResultadoDescuento(double d) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: const Text('Resultado'),
        content: Text('El descuento aplicado es ${d.toStringAsFixed(2)}%'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, 'recalcular'), child: const Text('Recalcular')),
          FilledButton(onPressed: () => Navigator.pop(context, 'continuar'), child: const Text('Continuar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calcular precio del oro')),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              ListTile(title: Text('Calcular precio del oro')),
              ListTile(title: Text('Calendario de obligaciones')),
              ListTile(title: Text('Biblioteca Minera')),
              ListTile(title: Text('Consultoría personalizada')),
              Divider(),
              ListTile(title: Text('Configuración de la cuenta')),
              ListTile(title: Text('Feedback sobre la app')),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Precio oro
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: precioOroCtrl,
                    etiqueta: 'Precio oro (USD/onza)',
                  ),
                ),
                buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) => _onGeneral(a, precioOroCtrl),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tipo de cambio
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: tipoCambioCtrl,
                    etiqueta: 'Tipo de cambio (S/ por USD)',
                  ),
                ),
                buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) => _onGeneral(a, tipoCambioCtrl),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Descuento
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: descuentoCtrl,
                    etiqueta: 'Descuento (%)',
                  ),
                ),
                buildMenu<DescuentoAction>(
                  icon: Icons.help_outline,
                  options: descuentoMenuOptions,
                  onSelected: _onDescuento,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ley
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: leyCtrl,
                    etiqueta: 'Ley (%)',
                  ),
                ),
                buildMenu<LeyAction>(
                  icon: Icons.help_outline,
                  options: leyMenuOptions,
                  onSelected: _onLey,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cantidad
            Row(
              children: [
                Expanded(
                  child: CampoNumerico(
                    controller: cantidadCtrl,
                    etiqueta: 'Cantidad (g)',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const AlertDialog(
                      content: Text('Coloque la cantidad de oro bruto en gramos que desea vender o calcular'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(onPressed: calcular, child: const Text('Calcular')),
            const SizedBox(height: 24),

            if (precioPorGramo != null)
              Text('Precio por gramo: ${soles(precioPorGramo!)}',
                  style: const TextStyle(fontSize: 18)),

            if (resultado != null)
              Text('Precio total: ${soles(resultado!)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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