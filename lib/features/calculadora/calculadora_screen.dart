import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/controllers/calculadora_controller.dart';
import '../../presentation/providers/parametros_providers.dart';
import '../../routes.dart';
import '../../core/utils/formatters.dart';
import '../../ui_kit/dialogs.dart';

import 'options/index.dart';
import 'widgets/precio_oro_field.dart';
import 'widgets/tipo_cambio_field.dart';
import 'widgets/descuento_field.dart';
import 'widgets/ley_field.dart';
import 'widgets/cantidad_field.dart';
import 'widgets/descuento_dialog.dart';

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

  static const Offset _menuOffsetUp = Offset(0, -36);

  @override
  void initState() {
    super.initState();
    // Cargar preferencias con el nuevo controller (Riverpod)
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

  /// Menú emergente genérico.
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

  /// Acción calcular: asegura sugeridos/ayudas y delega al controller.
  Future<void> _calcular() async {
    final sugeridos =
        ref.read(parametrosProvider).value ?? ParametrosRecomendados.defaults();
    final controller = ref.read(calculadoraControllerProvider.notifier);

    // Completar faltantes mínimos
    if (precioOroCtrl.text.trim().isEmpty) {
      precioOroCtrl.text = sugeridos.precioOroUsdOnza.toString();
    }
    if (tipoCambioCtrl.text.trim().isEmpty) {
      tipoCambioCtrl.text = sugeridos.tipoCambio.toString();
    }

    // Si descuento falta, ofrecer diálogo que también puede fijar ley
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

    // Si ley falta, dar opción simple (predeterminado o cancelar)
    if (leyCtrl.text.trim().isEmpty) {
      const optAyuda = 'Requiero ayuda';
      const optPred = 'Utilizar predeterminado';

      final sel = await choiceDialog(
        context: context,
        title: 'Ley faltante',
        message: 'No pusiste valores en ley.',
        options: const [optAyuda, optPred], // <-- orden correcto
      );

      if (sel == optPred) {
        leyCtrl.text = sugeridos.leySugerida.toString();
      } else {
        // Requiere ayuda o cerró el diálogo: no cambiamos nada y salimos.
        return;
      }
    }

    if (cantidadCtrl.text.trim().isEmpty) {
      cantidadCtrl.text = '1';
    }

    // Sincronizar al controller y calcular
    controller
      ..setPrecioOro(precioOroCtrl.text)
      ..setTipoCambio(tipoCambioCtrl.text)
      ..setDescuento(descuentoCtrl.text)
      ..setLey(leyCtrl.text)
      ..setCantidad(cantidadCtrl.text);

    await controller.calcular();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final sugeridos =
        ref.watch(parametrosProvider).value ??
        ParametrosRecomendados.defaults();
    final state = ref.watch(calculadoraControllerProvider);
    final controller = ref.read(calculadoraControllerProvider.notifier);

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
              /// Precio oro
              PrecioOroField(
                controller: precioOroCtrl,
                menu: buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) {
                    switch (a) {
                      case GeneralAction.actualizar:
                        precioOroCtrl.text = sugeridos.precioOroUsdOnza
                            .toString();
                        controller.setPrecioOro(precioOroCtrl.text);
                        setState(() {});
                        break;
                      default:
                        // No-op para otras acciones (si existen)
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              /// Tipo de cambio
              TipoCambioField(
                controller: tipoCambioCtrl,
                menu: buildMenu<GeneralAction>(
                  icon: Icons.settings,
                  options: generalMenuOptions,
                  onSelected: (a) {
                    switch (a) {
                      case GeneralAction.actualizar:
                        tipoCambioCtrl.text = sugeridos.tipoCambio.toString();
                        controller.setTipoCambio(tipoCambioCtrl.text);
                        setState(() {});
                        break;
                      default:
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              /// Descuento
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
                        descuentoCtrl.text = sugeridos.descuentoSugerido
                            .toString();
                        controller.setDescuento(descuentoCtrl.text);
                        setState(() {});
                        break;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              /// Ley
              LeyField(
                controller: leyCtrl,
                menu: buildMenu<LeyAction>(
                  icon: Icons.help_outline,
                  options: leyMenuOptions,
                  onSelected: (a) {
                    switch (a) {
                      case LeyAction.ayuda:
                        // TODO: flujo de ayuda de ley (si aplica)
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

              /// Cantidad
              CantidadField(
                controller: cantidadCtrl,
                menu: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const AlertDialog(
                      content: Text(
                        'Coloque la cantidad de oro bruto en gramos que desea vender o calcular',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Botón calcular
              ElevatedButton(
                onPressed: _calcular,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 24),

              /// --- RESULTADOS COMO "ANTES" ---
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
