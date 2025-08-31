import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_shell.dart';
import '../../presentation/controllers/calculadora_controller.dart';
import '../../presentation/providers/parametros_providers.dart';
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
    final sugeridos = ref.watch(parametrosProvider).value ?? ParametrosRecomendados.defaults();

    return AppShell(
      title: 'Calcular precio del oro',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrecioOroField(controller: precioOroCtrl, menu: const SizedBox.shrink()),
              const SizedBox(height: 12),
              TipoCambioField(controller: tipoCambioCtrl, menu: const SizedBox.shrink()),
              const SizedBox(height: 16),
              DescuentoField(
                controller: descuentoCtrl,
                menu: IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () async {
                    final ok = await showDescuentoDialog(
                      context: context,
                      precioOroCtrl: precioOroCtrl,
                      tipoCambioCtrl: tipoCambioCtrl,
                      descuentoCtrl: descuentoCtrl,
                      leyCtrl: leyCtrl,
                      sugeridos: sugeridos,
                    );
                    if (ok) {
                      controller.setDescuento(descuentoCtrl.text);
                      controller.setLey(leyCtrl.text);
                      setState(() {});
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              LeyField(controller: leyCtrl, menu: const SizedBox.shrink()),
              const SizedBox(height: 16),
              CantidadField(controller: cantidadCtrl),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  controller
                    ..setPrecioOro(precioOroCtrl.text)
                    ..setTipoCambio(tipoCambioCtrl.text)
                    ..setDescuento(descuentoCtrl.text)
                    ..setLey(leyCtrl.text)
                    ..setCantidad(cantidadCtrl.text);
                  await controller.calcular();
                },
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 24),
              ResultPanel(precioPorGramo: state.precioPorGramo, total: state.total),
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
