import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/providers/parametros_providers.dart';
import 'calculadora_controller.dart';
import 'calculadora_options.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/dialogs.dart';
import '../../widgets/campo_numerico.dart';

/// Widget: ScreenCalculadora - interfaz principal de la calculadora.
class ScreenCalculadora extends ConsumerStatefulWidget {
  const ScreenCalculadora({super.key});
  @override
  ConsumerState<ScreenCalculadora> createState() => _ScreenCalculadoraState();
}

/// State: _ScreenCalculadoraState - estado de la pantalla de cálculo.
class _ScreenCalculadoraState extends ConsumerState<ScreenCalculadora> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  final _controller = CalculadoraController();

  double? precioPorGramo;
  double? resultado;

  static const Offset _menuOffsetUp = Offset(0, -36);

  @override
  void initState() {
    super.initState();
    _controller.cargarPreferenciasInto(
      precioOro: precioOroCtrl,
      tipoCambio: tipoCambioCtrl,
      descuento: descuentoCtrl,
      ley: leyCtrl,
      cantidad: cantidadCtrl,
    ).then((_) => setState(() {}));
  }

  /// Función: buildMenu - crea un menú emergente genérico.
  PopupMenuButton<T> buildMenu<T>({
    required IconData icon,
    required List<MenuOption<T>> options,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      icon: Icon(icon),
      offset: _menuOffsetUp,
      itemBuilder: (_) => options
          .map((o) => PopupMenuItem<T>(
        value: o.value,
        child: Row(children: [
          Icon(o.icon, size: 20),
          const SizedBox(width: 10),
          Text(o.label),
        ]),
      ))
          .toList(),
      onSelected: onSelected,
    );
  }

  /// Función: calcular - ejecuta el cálculo utilizando los valores ingresados.
  Future<void> calcular() async {
    final sugeridos = ref.read(parametrosProvider).value ?? ParametrosRecomendados.defaults();

    if (precioOroCtrl.text.trim().isEmpty) precioOroCtrl.text = sugeridos.precioOroUsdOnza.toString();
    if (tipoCambioCtrl.text.trim().isEmpty) tipoCambioCtrl.text = sugeridos.tipoCambio.toString();

    if (descuentoCtrl.text.trim().isEmpty) {
      final sel = await choiceDialog(
        context: context,
        title: 'Descuento faltante',
        message: 'No pusiste valores en descuento.',
        options: const ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (sel == 'Utilizar predeterminado') {
        descuentoCtrl.text = sugeridos.descuentoSugerido.toString();
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
        leyCtrl.text = sugeridos.leySugerida.toString();
      } else {
        return;
      }
    }
    if (cantidadCtrl.text.trim().isEmpty) cantidadCtrl.text = '1';

    double parseNum(String s) => double.parse(s.replaceAll(',', '.'));

    final r = _controller.calcular(
      precioOro: parseNum(precioOroCtrl.text),
      tipoCambio: parseNum(tipoCambioCtrl.text),
      descuento: parseNum(descuentoCtrl.text),
      ley: parseNum(leyCtrl.text),
      cantidad: parseNum(cantidadCtrl.text),
    );

    setState(() {
      precioPorGramo = r.precioPorGramo;
      resultado = r.total;
    });

    await _controller.guardarPreferenciasFrom(
      precioOro: precioOroCtrl,
      tipoCambio: tipoCambioCtrl,
      descuento: descuentoCtrl,
      ley: leyCtrl,
      cantidad: cantidadCtrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncParams = ref.watch(parametrosProvider);
    final sugeridos = asyncParams.value ?? ParametrosRecomendados.defaults();

    return AppShell(
      title: 'Calcular precio del oro',
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
                  onSelected: (a) {
                    final changed = _controller.onGeneralAction(
                      a,
                      precioOroCtrl,
                      precioOroSugerido: sugeridos.precioOroUsdOnza,
                      tipoCambioSugerido: sugeridos.tipoCambio,
                      precioOroCtrl: precioOroCtrl,
                      tipoCambioCtrl: tipoCambioCtrl,
                    );
                    if (changed) setState(() {});
                  },
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
                  onSelected: (a) {
                    final changed = _controller.onGeneralAction(
                      a,
                      tipoCambioCtrl,
                      precioOroSugerido: sugeridos.precioOroUsdOnza,
                      tipoCambioSugerido: sugeridos.tipoCambio,
                      precioOroCtrl: precioOroCtrl,
                      tipoCambioCtrl: tipoCambioCtrl,
                    );
                    if (changed) setState(() {});
                  },
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
                  onSelected: (a) async {
                    switch (a) {
                      case DescuentoAction.ayuda:
                      case DescuentoAction.desdePrecio:
                        final ok = await _dialogoCalcularDescuentoConLey(sugeridos);
                        if (ok) setState(() {});
                        break;
                      case DescuentoAction.predeterminado:
                        descuentoCtrl.text = sugeridos.descuentoSugerido.toString();
                        setState(() {});
                        break;
                    }
                  },
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
                  onSelected: (a) {
                    switch (a) {
                      case LeyAction.ayuda:
                      // TODO: flujo de ayuda de ley
                        break;
                      case LeyAction.predeterminado:
                        leyCtrl.text = sugeridos.leySugerida.toString();
                        setState(() {});
                        break;
                    }
                  },
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
              Text('Precio por gramo: ${soles(precioPorGramo!)}', style: const TextStyle(fontSize: 18)),
            if (resultado != null)
              Text('Precio total: ${soles(resultado!)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Diálogo de ayuda (usa sugeridos del provider)
  /// Función: _dialogoCalcularDescuentoConLey - asistencia para calcular descuento.
  Future<bool> _dialogoCalcularDescuentoConLey(ParametrosRecomendados sugeridos) async {
    final precioOfrecidoCtrl = TextEditingController();
    final leyInputCtrl = TextEditingController(
      text: leyCtrl.text.isNotEmpty ? leyCtrl.text : sugeridos.leySugerida.toString(),
    );

    while (true) {
      final ok = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (_) => StatefulBuilder(
          builder: (context, setLocal) {
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
                        itemBuilder: (_) => leyMenuOptions
                            .map((o) => PopupMenuItem<LeyAction>(
                          value: o.value,
                          child: Row(children: [
                            Icon(o.icon, size: 18),
                            const SizedBox(width: 8),
                            Text(o.label),
                          ]),
                        ))
                            .toList(),
                        onSelected: (act) {
                          if (act == LeyAction.predeterminado) {
                            leyInputCtrl.text = sugeridos.leySugerida.toString();
                            setLocal(() {});
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

      if (ok != true) return false;

      final ofrecido = double.tryParse(precioOfrecidoCtrl.text.replaceAll(',', '.'));
      final leyUsada = double.tryParse(leyInputCtrl.text.replaceAll(',', '.')) ?? sugeridos.leySugerida;
      if (ofrecido == null || ofrecido <= 0) return false;

      final base = _controller.baseSolesPorGramo(
        precioOroUsdOnza: double.tryParse(precioOroCtrl.text.replaceAll(',', '.')) ?? sugeridos.precioOroUsdOnza,
        tipoCambio: double.tryParse(tipoCambioCtrl.text.replaceAll(',', '.')) ?? sugeridos.tipoCambio,
        leyPct: leyUsada,
      );

      double d = 100 * (1 - (ofrecido / base));
      if (d < 0) d = 0;
      if (d > 100) d = 100;

      final next = await showDialog<String>(
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

      if (next == 'recalcular') {
        continue;
      } else {
        descuentoCtrl.text = d.toStringAsFixed(2);
        leyCtrl.text = leyUsada.toStringAsFixed(2);
        return true;
      }
    }
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
