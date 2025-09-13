import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../infrastructure/datasources/exchange_rate_datasource.dart';
import '../atoms/general_action.dart';
import '../atoms/descuento_action.dart';
import '../atoms/ley_action.dart';
import '../molecules/precio_oro_field.dart';
import '../molecules/precio_oro_avanzadas_dialog.dart';
import '../molecules/tipo_cambio_field.dart';
import '../molecules/tipo_cambio_avanzadas_dialog.dart';
import '../molecules/descuento_field.dart';
import '../molecules/ley_field.dart';
import '../molecules/cantidad_field.dart';
import '../molecules/descuento_dialog.dart';
import 'package:toolmape/features/general/presentation/molecules/menu_popup_button.dart';
import 'package:toolmape/features/calculator/presentation/controllers/calculadora_controller.dart';
import 'package:toolmape/features/calculator/presentation/providers/parametros_providers.dart';

class CalculadoraForm extends StatelessWidget {
  const CalculadoraForm({
    super.key,
    required this.precioOroCtrl,
    required this.tipoCambioCtrl,
    required this.descuentoCtrl,
    required this.leyCtrl,
    required this.cantidadCtrl,
    required this.sugeridos,
    required this.vm,
    required this.onCalcular,
  });

  final TextEditingController precioOroCtrl;
  final TextEditingController tipoCambioCtrl;
  final TextEditingController descuentoCtrl;
  final TextEditingController leyCtrl;
  final TextEditingController cantidadCtrl;
  final ParametrosRecomendados sugeridos;
  final CalculadoraViewModel vm;
  final Future<void> Function() onCalcular;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontal = size.width >= size.height;

    Future<void> _actualizarPrecioOro() async {
      final row = await Supabase.instance.client
          .from('stg_spot_ticks')
          .select('price')
          .filter('metal_code', 'in', '("XAU","xau","GOLD","Gold","gold")')
          .ilike('currency', 'usd')
          .order('captured_at', ascending: false)
          .limit(1)
          .maybeSingle();
      final price = (row?['price'] as num?)?.toDouble();
      if (price != null) {
        precioOroCtrl.text = price.toStringAsFixed(2);
        vm.setPrecioOro(precioOroCtrl.text);
      }
    }

    Future<void> _actualizarTipoCambio() async {
      final ds = ExchangeRateDatasource(Supabase.instance.client);
      final res = await ds.fetchLatest();
      final tc = res.value;
      if (tc != null) {
        tipoCambioCtrl.text = tc.toStringAsFixed(2);
        vm.setTipoCambio(tipoCambioCtrl.text);
      }
    }

    Future<void> _actualizarDatos() async {
      await _actualizarPrecioOro();
      await _actualizarTipoCambio();
    }

    Widget buildPrecioOro() => PrecioOroField(
          controller: precioOroCtrl,
          menu: MenuPopupButton<PrecioOroAction>(
            icon: Icons.settings,
            options: precioOroMenuOptions,
            onSelected: (a) async {
              switch (a) {
                case PrecioOroAction.actualizar:
                  await _actualizarDatos();
                  break;
                case PrecioOroAction.avanzadas:
                  final sel = await showPrecioOroAvanzadasDialog(context);
                  if (sel != null) {
                    precioOroCtrl.text = sel.toStringAsFixed(2);
                    vm.setPrecioOro(precioOroCtrl.text);
                  }
                  break;
                case PrecioOroAction.tiempoReal:
                  try {
                    await http
                        .post(Uri.parse(
                      'https://eifdvmxqabyzxthddbrh.supabase.co/functions/v1/ingest_spot_ticks',
                    ))
                        .timeout(const Duration(seconds: 15));
                  } catch (_) {
                  } finally {
                    await _actualizarDatos();
                  }
                  break;
                case PrecioOroAction.analisis:
                  break;
              }
            },
          ),
        );

    Widget buildTipoCambio() => TipoCambioField(
          controller: tipoCambioCtrl,
          menu: MenuPopupButton<TipoCambioAction>(
            icon: Icons.settings,
            options: tipoCambioMenuOptions,
            onSelected: (a) async {
              switch (a) {
                case TipoCambioAction.actualizar:
                  await _actualizarDatos();
                  break;
                case TipoCambioAction.avanzadas:
                  final sel = await showTipoCambioAvanzadasDialog(context);
                  if (sel != null) {
                    final rate = sel.rate;
                    final gold = sel.goldPrice;
                    if (rate != null) {
                      tipoCambioCtrl.text = rate.toStringAsFixed(2);
                      vm.setTipoCambio(tipoCambioCtrl.text);
                    }
                    if (gold != null) {
                      precioOroCtrl.text = gold.toStringAsFixed(2);
                      vm.setPrecioOro(precioOroCtrl.text);
                    }
                  }
                  break;
                case TipoCambioAction.tiempoReal:
                  try {
                    await http
                        .post(Uri.parse(
                      'https://eifdvmxqabyzxthddbrh.supabase.co/functions/v1/ingest_latest_ticks',
                    ))
                        .timeout(const Duration(seconds: 15));
                  } catch (_) {
                  } finally {
                    await _actualizarDatos();
                  }
                  break;
              }
            },
          ),
        );

    Widget buildDescuento() => DescuentoField(
          controller: descuentoCtrl,
          menu: MenuPopupButton<DescuentoAction>(
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
                  descuentoCtrl.text =
                      sugeridos.descuentoSugerido.toString();
                  vm.setDescuento(descuentoCtrl.text);
                  break;
              }
            },
          ),
        );

    Widget buildLey() => LeyField(
          controller: leyCtrl,
          menu: MenuPopupButton<LeyAction>(
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
        );

    Widget buildCantidad() => CantidadField(
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
        );

    final button = FilledButton(
      onPressed: onCalcular,
      style: Theme.of(context).brightness == Brightness.dark
          ? FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            )
          : null,
      child: const Text('Calcular'),
    );

    if (horizontal) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: buildPrecioOro()),
              const SizedBox(width: 16),
              Expanded(child: buildTipoCambio()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: buildDescuento()),
              const SizedBox(width: 16),
              Expanded(child: buildLey()),
            ],
          ),
          const SizedBox(height: 16),
          buildCantidad(),
          const SizedBox(height: 24),
          button,
        ],
      );
    }

    return Column(
      children: [
        buildPrecioOro(),
        const SizedBox(height: 12),
        buildTipoCambio(),
        const SizedBox(height: 16),
        buildDescuento(),
        const SizedBox(height: 16),
        buildLey(),
        const SizedBox(height: 16),
        buildCantidad(),
        const SizedBox(height: 24),
        button,
      ],
    );
  }
}
