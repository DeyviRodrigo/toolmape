import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/controllers/calculadora_controller.dart';
import '../../presentation/providers/parametros_providers.dart';
import '../../core/utils/dialogs.dart';
import 'calculadora_options.dart';
import 'widgets/precio_oro_field.dart';
import 'widgets/tipo_cambio_field.dart';
import 'widgets/descuento_field.dart';
import 'widgets/ley_field.dart';
import 'widgets/cantidad_field.dart';
import 'widgets/result_panel.dart';
import 'widgets/descuento_dialog.dart';

class ScreenCalculadora extends ConsumerStatefulWidget {
  const ScreenCalculadora({super.key});

  @override
  ConsumerState<ScreenCalculadora> createState() => _ScreenCalculadoraState();
}

class _ScreenCalculadoraState extends ConsumerState<ScreenCalculadora> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  static const Offset _menuOffsetUp = Offset(0, -36);

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

  Future<void> _calcular() async {
    final sugeridos =
        ref.read(parametrosProvider).value ?? ParametrosRecomendados.defaults();
    if (precioOroCtrl.text.trim().isEmpty) {
      precioOroCtrl.text = sugeridos.precioOroUsdOnza.toString();
    }
    if (tipoCambioCtrl.text.trim().isEmpty) {
      tipoCambioCtrl.text = sugeridos.tipoCambio.toString();
    }
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
    if (cantidadCtrl.text.trim().isEmpty) {
      cantidadCtrl.text = '1';
    }

    final controller = ref.read(calculadoraControllerProvider.notifier)
      ..setPrecioOro(precioOroCtrl.text)
      ..setTipoCambio(tipoCambioCtrl.text)
      ..setDescuento(descuentoCtrl.text)
      ..setLey(leyCtrl.text)
      ..setCantidad(cantidadCtrl.text);
    await controller.calcular();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ref.read(calculadoraControllerProvider.notifier).cargar().then((_) {
      final s = ref.read(calculadoraControllerProvider);
      precioOroCtrl.text = s.precioOro;
      tipoCambioCtrl.text = s.tipoCambio;
      descuentoCtrl.text = s.descuento;
      leyCtrl.text = s.ley;
      cantidadCtrl.text = s.cantidad;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calculadoraControllerProvider);
    final controller = ref.read(calculadoraControllerProvider.notifier);
    final sugeridos =
        ref.watch(parametrosProvider).value ?? ParametrosRecomendados.defaults();

    return AppShell(
      title: 'Calcular precio del oro',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PrecioOroField(
                controller: precioOroCtrl,
                menu: buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) {
                    if (a == GeneralAction.actualizar) {
                      precioOroCtrl.text =
                          sugeridos.precioOroUsdOnza.toString();
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TipoCambioField(
                controller: tipoCambioCtrl,
                menu: buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) {
                    if (a == GeneralAction.actualizar) {
                      tipoCambioCtrl.text = sugeridos.tipoCambio.toString();
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              DescuentoField(
                controller: descuentoCtrl,
                menu: buildMenu<DescuentoAction>(
                  icon: Icons.help_outline,
                  options: descuentoMenuOptions,
                  onSelected: (a) async {
                    switch (a) {
                      case DescuentoAction.ayuda:
                      case DescuentoAction.desdePrecio:
                        final ok = await showDescuentoDialog(
                          context: context,
                          precioOroCtrl: precioOroCtrl,
                          tipoCambioCtrl: tipoCambioCtrl,
                          descuentoCtrl: descuentoCtrl,
                          leyCtrl: leyCtrl,
                          sugeridos: sugeridos,
                        );
                        if (ok) {
                          controller
                            ..setDescuento(descuentoCtrl.text)
                            ..setLey(leyCtrl.text);
                          setState(() {});
                        }
                        break;
                      case DescuentoAction.predeterminado:
                        descuentoCtrl.text =
                            sugeridos.descuentoSugerido.toString();
                        controller.setDescuento(descuentoCtrl.text);
                        setState(() {});
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              LeyField(
                controller: leyCtrl,
                menu: buildMenu<LeyAction>(
                  icon: Icons.help_outline,
                  options: leyMenuOptions,
                  onSelected: (a) {
                    switch (a) {
                      case LeyAction.ayuda:
                        break;
                      case LeyAction.predeterminado:
                        leyCtrl.text = sugeridos.leySugerida.toString();
                        controller.setLey(leyCtrl.text);
                        setState(() {});
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              CantidadField(
                controller: cantidadCtrl,
                menu: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const AlertDialog(
                      content: Text(
                          'Coloque la cantidad de oro bruto en gramos que desea vender o calcular'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calcular,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 24),
              ResultPanel(
                precioPorGramo: state.precioPorGramo,
                total: state.total,
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
