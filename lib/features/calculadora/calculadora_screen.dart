import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/viewmodels/calculadora_view_model.dart';
import '../../presentation/providers/parametros_providers.dart';
import '../../routes.dart';
import '../../core/utils/formatters.dart';
import '../../ui_kit/dialogs.dart';
import '../../presentation/shared/general_action.dart';
import '../../presentation/shared/descuento_action.dart';
import '../../presentation/shared/ley_action.dart';
import '../../presentation/shared/menu_option.dart';

import 'widgets/precio_oro_field.dart';
import 'widgets/tipo_cambio_field.dart';
import 'widgets/descuento_field.dart';
import 'widgets/ley_field.dart';
import 'widgets/cantidad_field.dart';
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

  @override
  void initState() {
    super.initState();
    ref.read(calculadoraViewModelProvider.notifier).cargar().then((_) async {
      final s = ref.read(calculadoraViewModelProvider);
      descuentoCtrl.text = s.descuento;
      leyCtrl.text = s.ley;
      cantidadCtrl.text = s.cantidad;
      try {
        final p = await ref.refresh(parametrosProvider.future);
        precioOroCtrl.text = p.precioOroUsdOnza.toString();
        tipoCambioCtrl.text = p.tipoCambio.toString();
      } catch (_) {
        // En caso de error, los campos quedan vacíos para usar defaults.
      }
      setState(() {});
    });
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

  Future<void> _calcular() async {
    final sugeridos =
        ref.read(parametrosProvider).value ?? ParametrosRecomendados.defaults();
    final vm = ref.read(calculadoraViewModelProvider.notifier);

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
      final sel = await choiceDialog(
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
    final sugeridos =
        ref.watch(parametrosProvider).value ??
        ParametrosRecomendados.defaults();
    final state = ref.watch(calculadoraViewModelProvider);
    final vm = ref.read(calculadoraViewModelProvider.notifier);

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
              _CalculadoraForm(
                precioOroCtrl: precioOroCtrl,
                tipoCambioCtrl: tipoCambioCtrl,
                descuentoCtrl: descuentoCtrl,
                leyCtrl: leyCtrl,
                cantidadCtrl: cantidadCtrl,
                sugeridos: sugeridos,
                vm: vm,
                onCalcular: _calcular,
                buildMenu: buildMenu,
              ),
              const SizedBox(height: 24),
              _Resultados(state: state),
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

class _CalculadoraForm extends StatelessWidget {
  const _CalculadoraForm({
    required this.precioOroCtrl,
    required this.tipoCambioCtrl,
    required this.descuentoCtrl,
    required this.leyCtrl,
    required this.cantidadCtrl,
    required this.sugeridos,
    required this.vm,
    required this.onCalcular,
    required this.buildMenu,
  });

  final TextEditingController precioOroCtrl;
  final TextEditingController tipoCambioCtrl;
  final TextEditingController descuentoCtrl;
  final TextEditingController leyCtrl;
  final TextEditingController cantidadCtrl;
  final ParametrosRecomendados sugeridos;
  final CalculadoraViewModel vm;
  final Future<void> Function() onCalcular;
  final PopupMenuButton<T> Function<T>({
    required IconData icon,
    required List<MenuOption<T>> options,
    required void Function(T) onSelected,
  }) buildMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrecioOroField(
          controller: precioOroCtrl,
          menu: buildMenu<GeneralAction>(
            icon: Icons.settings,
            options: generalMenuOptions,
            onSelected: (a) {
              switch (a) {
                case GeneralAction.actualizar:
                  precioOroCtrl.text = sugeridos.precioOroUsdOnza.toString();
                  vm.setPrecioOro(precioOroCtrl.text);
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
                  tipoCambioCtrl.text = sugeridos.tipoCambio.toString();
                  vm.setTipoCambio(tipoCambioCtrl.text);
                  break;
                default:
                  break;
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
                    vm
                      ..setDescuento(descuentoCtrl.text)
                      ..setLey(leyCtrl.text);
                  }
                  break;
                case DescuentoAction.predeterminado:
                  descuentoCtrl.text = sugeridos.descuentoSugerido.toString();
                  vm.setDescuento(descuentoCtrl.text);
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
                      content: Text('La ley representa la pureza del oro. Consulta a un perito para obtenerla.'),
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
        CantidadField(
          controller: cantidadCtrl,
          menu: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showDialog(
              context: context,
              barrierDismissible: true,
              builder: (_) => const AlertDialog(
                content: Text('Coloque la cantidad de oro bruto en gramos que desea vender o calcular'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onCalcular,
          child: const Text('Calcular'),
        ),
      ],
    );
  }
}

class _Resultados extends StatelessWidget {
  const _Resultados({required this.state});
  final CalculadoraState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (state.precioPorGramo != null)
          Text(
            'Precio por gramo: ${soles(state.precioPorGramo!)}',
            style: const TextStyle(fontSize: 18),
          ),
        if (state.total != null)
          Text(
            'Precio total: ${soles(state.total!)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
