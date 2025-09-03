import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/viewmodels/descuento_view_model.dart';
import '../../presentation/viewmodels/calculadora_view_model.dart';
import '../../presentation/providers/parametros_providers.dart';
import '../../presentation/shared/general_action.dart';
import '../../presentation/shared/ley_action.dart';
import '../../presentation/shared/menu_option.dart';
import '../../presentation/shared/menu_builder.dart';
import '../../routes.dart';

import 'widgets/precio_oro_field.dart';
import 'widgets/precio_oro_avanzadas_dialog.dart';
import 'widgets/tipo_cambio_field.dart';
import 'widgets/ley_field.dart';
import 'widgets/precio_ofrecido_field.dart';

class ScreenCalcularDescuento extends ConsumerStatefulWidget {
  const ScreenCalcularDescuento({super.key});

  @override
  ConsumerState<ScreenCalcularDescuento> createState() => _ScreenCalcularDescuentoState();
}

class _ScreenCalcularDescuentoState extends ConsumerState<ScreenCalcularDescuento> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  bool _warnedOffline = false;

  @override
  void initState() {
    super.initState();
    ref.read(parametrosProvider.future).then((p) {
      final gold = p.precioOroUsdOnza.toStringAsFixed(2);
      final tc = p.tipoCambio.toStringAsFixed(2);
      precioOroCtrl.text = gold;
      tipoCambioCtrl.text = tc;
      final vm = ref.read(descuentoViewModelProvider.notifier);
      vm
        ..setPrecioOro(gold)
        ..setTipoCambio(tc);
      setState(() {});
    });
  }

  Future<void> _calcular() async {
    final vm = ref.read(descuentoViewModelProvider.notifier);
    vm
      ..setPrecioOro(precioOroCtrl.text)
      ..setTipoCambio(tipoCambioCtrl.text)
      ..setLey(leyCtrl.text)
      ..setPrecio(precioCtrl.text);
    await vm.calcular();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(parametrosOfflineProvider, (prev, next) {
      if (next && !_warnedOffline) {
        _warnedOffline = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('No pudimos conectarnos a internet'),
              content: const Text(
                  'Es probable que los valores que muestre el aplicativo no correspondan al último valor registrado del oro y el tipo de cambio, no utilice el aplicativo para hacer cálculos para la compra y venta de oro.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    });

    final sugeridos =
        ref.watch(parametrosProvider).value ?? ParametrosRecomendados.defaults();
    final state = ref.watch(descuentoViewModelProvider);
    final vm = ref.read(descuentoViewModelProvider.notifier);

    return AppShell(
      title: 'Calcular descuento',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalcularDescuento: () =>
          Navigator.pushReplacementNamed(context, routeCalcularDescuento),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
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
                  onSelected: (a) async {
                    switch (a) {
                      case GeneralAction.actualizar:
                        precioOroCtrl.text =
                            sugeridos.precioOroUsdOnza.toStringAsFixed(2);
                        vm.setPrecioOro(precioOroCtrl.text);
                        break;
                      case GeneralAction.avanzadas:
                        final sel = await showPrecioOroAvanzadasDialog(context);
                        if (sel != null) {
                          precioOroCtrl.text = sel.toStringAsFixed(2);
                          vm.setPrecioOro(precioOroCtrl.text);
                        }
                        break;
                      default:
                        break;
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
                    switch (a) {
                      case GeneralAction.actualizar:
                        tipoCambioCtrl.text =
                            sugeridos.tipoCambio.toStringAsFixed(2);
                        vm.setTipoCambio(tipoCambioCtrl.text);
                        break;
                      default:
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
                  onSelected: (a) async {
                    switch (a) {
                      case LeyAction.ayuda:
                        await showDialog(
                          context: context,
                          builder: (_) => const AlertDialog(
                            content: Text(
                                'La ley representa la pureza del oro. Consulta a un perito para obtenerla.'),
                          ),
                        );
                        break;
                      case LeyAction.predeterminado:
                        leyCtrl.text = sugeridos.leySugerida.toString();
                        vm.setLey(leyCtrl.text);
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              PrecioOfrecidoField(
                controller: precioCtrl,
                menu: const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calcular,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 24),
              if (state.descuento != null)
                Column(
                  children: [
                    Text(
                      'Descuento: ${state.descuento!.toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final calcVm =
                            ref.read(calculadoraViewModelProvider.notifier);
                        calcVm
                          ..setPrecioOro(precioOroCtrl.text)
                          ..setTipoCambio(tipoCambioCtrl.text)
                          ..setDescuento(state.descuento!.toStringAsFixed(2))
                          ..setLey(leyCtrl.text);
                        Navigator.pushReplacementNamed(
                            context, routeCalculadora);
                      },
                      child: const Text('Usar este descuento'),
                    ),
                  ],
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
    leyCtrl.dispose();
    precioCtrl.dispose();
    super.dispose();
  }
}
