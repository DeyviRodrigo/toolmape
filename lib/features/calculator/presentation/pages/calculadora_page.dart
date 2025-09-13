import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/calculator/presentation/viewmodels/calculator_view_model.dart';
import 'package:toolmape/features/calculator/presentation/viewmodels/parametros_view_model.dart';
import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/core/utils/formatters.dart';
import 'package:toolmape/features/general/presentation/molecules/confirm_dialog.dart';

import '../organisms/calculadora_form.dart';
import '../molecules/resultados.dart';
import '../molecules/descuento_dialog.dart';

class CalculadoraPage extends ConsumerStatefulWidget {
  const CalculadoraPage({super.key});

  @override
  ConsumerState<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends ConsumerState<CalculadoraPage> {
  final precioOroCtrl = TextEditingController();
  final tipoCambioCtrl = TextEditingController();
  final descuentoCtrl = TextEditingController();
  final leyCtrl = TextEditingController();
  final cantidadCtrl = TextEditingController();

  bool _warnedOffline = false;

  @override
  void initState() {
    super.initState();
    ref.read(calculatorViewModelProvider.notifier).cargar().then((_) {
      final s = ref.read(calculatorViewModelProvider);
      precioOroCtrl.text = s.precioOro;
      tipoCambioCtrl.text = s.tipoCambio;
      descuentoCtrl.text = s.descuento;
      leyCtrl.text = s.ley;
      cantidadCtrl.text = s.cantidad;
      setState(() {});
    });
    ref.read(parametrosViewModelProvider.future).then((p) {
      final gold = p.precioOroUsdOnza.toStringAsFixed(2);
      final tc = p.tipoCambio.toStringAsFixed(2);
      precioOroCtrl.text = gold;
      tipoCambioCtrl.text = tc;
      final vm = ref.read(calculatorViewModelProvider.notifier);
      vm
        ..setPrecioOro(gold)
        ..setTipoCambio(tc);
      setState(() {});
    });
  }

  Future<void> _calcular() async {
    final sugeridos =
        ref.read(parametrosViewModelProvider).value ?? ParametrosRecomendados.defaults();
    final vm = ref.read(calculatorViewModelProvider.notifier);

    if (precioOroCtrl.text.trim().isEmpty) {
      precioOroCtrl.text = sugeridos.precioOroUsdOnza.toStringAsFixed(2);
    }
    if (tipoCambioCtrl.text.trim().isEmpty) {
      tipoCambioCtrl.text = sugeridos.tipoCambio.toStringAsFixed(2);
    }
    if (descuentoCtrl.text.trim().isEmpty) {
      final sel = await showConfirmDialog(
        context: context,
        title: 'Descuento faltante',
        message: 'No pusiste valores en descuento.',
        options: const ['Requiero ayuda', 'Utilizar predeterminado'],
      );
      if (sel == 'Requiero ayuda') {
        final ok = await showDescuentoDialog(
          context: context,
          precioOroCtrl: precioOroCtrl,
          tipoCambioCtrl: tipoCambioCtrl,
          descuentoCtrl: descuentoCtrl,
          leyCtrl: leyCtrl,
          sugeridos: sugeridos,
        );
        if (!ok) return;
      } else if (sel == 'Utilizar predeterminado') {
        descuentoCtrl.text = sugeridos.descuentoSugerido.toString();
      } else {
        return;
      }
    }

    if (leyCtrl.text.trim().isEmpty) {
      const optAyuda = 'Requiero ayuda';
      const optPred = 'Utilizar predeterminado';
      final sel = await showConfirmDialog(
        context: context,
        title: 'Ley faltante',
        message: 'No pusiste valores en ley.',
        options: const [optAyuda, optPred],
      );
      if (sel == optPred) {
        leyCtrl.text = sugeridos.leySugerida.toString();
      } else {
        return;
      }
    }

    if (cantidadCtrl.text.trim().isEmpty) {
      cantidadCtrl.text = '1';
    }

    vm
      ..setPrecioOro(precioOroCtrl.text)
      ..setTipoCambio(tipoCambioCtrl.text)
      ..setDescuento(descuentoCtrl.text)
      ..setLey(leyCtrl.text)
      ..setCantidad(cantidadCtrl.text);

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
        ref.watch(parametrosViewModelProvider).value ??
        ParametrosRecomendados.defaults();
    final state = ref.watch(calculatorViewModelProvider);
    final vm = ref.read(calculatorViewModelProvider.notifier);

    return AppShell(
      title: 'Calcular precio del oro',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CalculadoraForm(
                precioOroCtrl: precioOroCtrl,
                tipoCambioCtrl: tipoCambioCtrl,
                descuentoCtrl: descuentoCtrl,
                leyCtrl: leyCtrl,
                cantidadCtrl: cantidadCtrl,
                sugeridos: sugeridos,
                vm: vm,
                onCalcular: _calcular,
              ),
              const SizedBox(height: 24),
              Resultados(state: state),
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

