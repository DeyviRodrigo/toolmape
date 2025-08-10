import 'package:flutter/material.dart';

import 'calculadora_controller.dart';
import 'calculadora_options.dart';
import 'calculadora_constants.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/dialogs.dart';
import '../../widgets/campo_numerico.dart';

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

  final _controller = CalculadoraController();

  double? precioPorGramo;
  double? resultado;

  static const Offset _menuOffsetUp = Offset(0, -36);

  @override
  void initState() {
    super.initState();
    _controller
        .cargarPreferenciasInto(
      precioOro: precioOroCtrl,
      tipoCambio: tipoCambioCtrl,
      descuento: descuentoCtrl,
      ley: leyCtrl,
      cantidad: cantidadCtrl,
    )
        .then((_) => setState(() {}));
  }

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
        child: Row(
          children: [
            Icon(o.icon, size: 20),
            const SizedBox(width: 10),
            Text(o.label),
          ],
        ),
      ))
          .toList(),
      onSelected: onSelected,
    );
  }

  Future<void> calcular() async {
    if (precioOroCtrl.text.trim().isEmpty) precioOroCtrl.text = kPrecioOroDefault.toString();
    if (tipoCambioCtrl.text.trim().isEmpty) tipoCambioCtrl.text = kTipoCambioDefault.toString();

    if (descuentoCtrl.text.trim().isEmpty) {
      final sel = await choiceDialog(
        context: context,
        title: 'Descuento faltante',
        message: 'No pusiste valores en descuento.',
        options: const ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (sel == 'Utilizar predeterminado') {
        descuentoCtrl.text = kDescuentoDefault.toString();
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
        leyCtrl.text = kLeyDefault.toString();
      } else {
        return;
      }
    }
    if (cantidadCtrl.text.trim().isEmpty) cantidadCtrl.text = '1';

    double _p(String s) => double.parse(s.replaceAll(',', '.'));

    final r = _controller.calcular(
      precioOro: _p(precioOroCtrl.text),
      tipoCambio: _p(tipoCambioCtrl.text),
      descuento: _p(descuentoCtrl.text),
      ley: _p(leyCtrl.text),
      cantidad: _p(cantidadCtrl.text),
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
    return Scaffold(
      // Drawer IZQUIERDO (restaurado)
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const ListTile(
                title: Text('Calcular precio del oro'),
                leading: Icon(Icons.calculate_outlined),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Calendario de obligaciones'),
                onTap: () {/* TODO: navegar */},
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Biblioteca Minera'),
                onTap: () {/* TODO: navegar */},
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Consultoría personalizada'),
                onTap: () {/* TODO: navegar */},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración de la cuenta'),
                onTap: () {/* TODO: navegar */},
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Dejar feedback sobre la app'),
                onTap: () {/* TODO: navegar */},
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        title: const Text('Calcular precio del oro'),
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
                  onSelected: (a) {
                    final changed = _controller.onGeneralAction(
                      a,
                      precioOroCtrl,
                      precioOro: precioOroCtrl,
                      tipoCambio: tipoCambioCtrl,
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
                      precioOro: precioOroCtrl,
                      tipoCambio: tipoCambioCtrl,
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
                        final applied = await _controller.dialogoCalcularDescuentoConLey(
                          context: context,
                          leyMenuOptions: leyMenuOptions,
                          descuentoCtrl: descuentoCtrl,
                          leyCtrl: leyCtrl,
                          precioOroCtrl: precioOroCtrl,
                          tipoCambioCtrl: tipoCambioCtrl,
                        );
                        if (applied) setState(() {});
                        break;
                      case DescuentoAction.predeterminado:
                        descuentoCtrl.text = kDescuentoDefault.toString();
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
                        leyCtrl.text = kLeyDefault.toString();
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
