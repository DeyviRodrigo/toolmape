import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/app/app_shell.dart';
import 'package:toolmape/features/calculator/presentation/controllers/calculadora_controller.dart';
import 'package:toolmape/features/calculator/presentation/providers/parametros_providers.dart';
import 'package:toolmape/app/routes.dart';
import '../../core/utils/formatters.dart';
import 'package:toolmape/design_system/molecules/confirm_dialog.dart';
import 'package:toolmape/presentation/shared/general_action.dart';
import 'package:toolmape/presentation/shared/descuento_action.dart';
import 'package:toolmape/presentation/shared/ley_action.dart';
import 'package:toolmape/presentation/shared/menu_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../molecules/precio_oro_field.dart';
import '../molecules/precio_oro_avanzadas_dialog.dart';
import '../molecules/tipo_cambio_field.dart';
import '../molecules/tipo_cambio_avanzadas_dialog.dart';
import '../molecules/descuento_field.dart';
import '../molecules/ley_field.dart';
import '../molecules/cantidad_field.dart';
import '../molecules/descuento_dialog.dart';
import '../../data/exchange_rate_datasource.dart';

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

  static const Offset _menuOffsetUp = Offset(0, -36);

  bool _warnedOffline = false;

  @override
  void initState() {
    super.initState();
    ref.read(calculadoraViewModelProvider.notifier).cargar().then((_) {
      final s = ref.read(calculadoraViewModelProvider);
      precioOroCtrl.text = s.precioOro;
      tipoCambioCtrl.text = s.tipoCambio;
      descuentoCtrl.text = s.descuento;
      leyCtrl.text = s.ley;
      cantidadCtrl.text = s.cantidad;
      setState(() {});
    });
    ref.read(parametrosProvider.future).then((p) {
      final gold = p.precioOroUsdOnza.toStringAsFixed(2);
      final tc = p.tipoCambio.toStringAsFixed(2);
      precioOroCtrl.text = gold;
      tipoCambioCtrl.text = tc;
      final vm = ref.read(calculadoraViewModelProvider.notifier);
      vm
        ..setPrecioOro(gold)
        ..setTipoCambio(tc);
      setState(() {});
    });
  }

  PopupMenuButton<T> buildMenu<T>({
    required Widget icon,
    required List<MenuOption<T>> options,
    required void Function(T) onSelected,
  }) {
    return PopupMenuButton<T>(
      icon: icon,
      offset: _menuOffsetUp,
      itemBuilder: (_) => options
          .map(
            (o) => PopupMenuItem<T>(
              value: o.value,
              child: Row(
                children: [
                  Icon(o.icon, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      o.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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

class _CalculadoraForm extends StatefulWidget {
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
    required Widget icon,
    required List<MenuOption<T>> options,
    required void Function(T) onSelected,
  }) buildMenu;

  @override
  State<_CalculadoraForm> createState() => _CalculadoraFormState();
}

class _CalculadoraFormState extends State<_CalculadoraForm> {
  bool _loadingPrecioOro = false;
  bool _loadingTipoCambio = false;
  DateTime? _spotCapturedAt;
  DateTime? _latestCapturedAt;

  Future<({DateTime? spot, DateTime? latest})> _actualizarDatos() async {
    final client = Supabase.instance.client;
    DateTime? spotAt;

    final row = await client
        .from('spot')
        .select('price, captured_at')
        .filter('metal_code', 'in', '("XAU","xau","GOLD","Gold","gold")')
        .ilike('currency', 'usd')
        .order('captured_at', ascending: false)
        .limit(1)
        .maybeSingle();
    final price = (row?['price'] as num?)?.toDouble();
    spotAt = DateTime.tryParse('${row?['captured_at']}')?.toLocal();
    if (price != null) {
      widget.precioOroCtrl.text = price.toStringAsFixed(2);
      widget.vm.setPrecioOro(widget.precioOroCtrl.text);
    }

    final ds = ExchangeRateDatasource(client);
    final res = await ds.fetchLatest();
    final tc = res.value;
    final latestAt = res.capturedAt;
    if (tc != null) {
      widget.tipoCambioCtrl.text = tc.toStringAsFixed(2);
      widget.vm.setTipoCambio(widget.tipoCambioCtrl.text);
    }

    setState(() {
      _spotCapturedAt = spotAt;
      _latestCapturedAt = latestAt;
    });

    return (spot: spotAt, latest: latestAt);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final horizontal = size.width >= size.height;

    Widget buildPrecioOro() => PrecioOroField(
          controller: widget.precioOroCtrl,
          menu: widget.buildMenu<PrecioOroAction>(
            icon: _loadingPrecioOro
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.settings),
            options: precioOroMenuOptions,
            onSelected: (a) async {
              switch (a) {
                case PrecioOroAction.actualizar:
                  await _actualizarDatos();
                  break;
                case PrecioOroAction.avanzadas:
                  final sel = await showPrecioOroAvanzadasDialog(context);
                  if (sel != null) {
                    widget.precioOroCtrl.text = sel.toStringAsFixed(2);
                    widget.vm.setPrecioOro(widget.precioOroCtrl.text);
                  }
                  break;
                case PrecioOroAction.tiempoReal:
                  setState(() => _loadingPrecioOro = true);
                  await _actualizarDatos();
                  final prev = _spotCapturedAt;
                  await http.post(Uri.parse(
                      'https://eifdvmxqabyzxthddbrh.supabase.co/functions/v1/ingest_spot_ticks'));
                  do {
                    await Future.delayed(const Duration(seconds: 1));
                    await _actualizarDatos();
                  } while (_spotCapturedAt == null || _spotCapturedAt == prev);
                  setState(() => _loadingPrecioOro = false);
                  break;
                case PrecioOroAction.analisis:
                  break;
              }
            },
          ),
        );

    Widget buildTipoCambio() => TipoCambioField(
          controller: widget.tipoCambioCtrl,
          menu: widget.buildMenu<TipoCambioAction>(
            icon: _loadingTipoCambio
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.settings),
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
                      widget.tipoCambioCtrl.text = rate.toStringAsFixed(2);
                      widget.vm.setTipoCambio(widget.tipoCambioCtrl.text);
                    }
                    if (gold != null) {
                      widget.precioOroCtrl.text = gold.toStringAsFixed(2);
                      widget.vm.setPrecioOro(widget.precioOroCtrl.text);
                    }
                  }
                  break;
                case TipoCambioAction.tiempoReal:
                  setState(() => _loadingTipoCambio = true);
                  await _actualizarDatos();
                  final prev = _latestCapturedAt;
                  await http.post(Uri.parse(
                      'https://eifdvmxqabyzxthddbrh.supabase.co/functions/v1/ingest_latest_ticks'));
                  do {
                    await Future.delayed(const Duration(seconds: 1));
                    await _actualizarDatos();
                  } while (_latestCapturedAt == null || _latestCapturedAt == prev);
                  setState(() => _loadingTipoCambio = false);
                  break;
              }
            },
          ),
        );

    Widget buildDescuento() => DescuentoField(
          controller: widget.descuentoCtrl,
          menu: widget.buildMenu<DescuentoAction>(
            icon: const Icon(Icons.help_outline),
            options: descuentoMenuOptions,
            onSelected: (a) async {
              switch (a) {
                case DescuentoAction.ayuda:
                case DescuentoAction.desdePrecio:
                  final ok = await showDescuentoDialog(
                    context: context,
                    precioOroCtrl: widget.precioOroCtrl,
                    tipoCambioCtrl: widget.tipoCambioCtrl,
                    descuentoCtrl: widget.descuentoCtrl,
                    leyCtrl: widget.leyCtrl,
                    sugeridos: widget.sugeridos,
                  );
                  if (ok) {
                    widget.vm
                      ..setDescuento(widget.descuentoCtrl.text)
                      ..setLey(widget.leyCtrl.text);
                  }
                  break;
                case DescuentoAction.predeterminado:
                  widget.descuentoCtrl.text =
                      widget.sugeridos.descuentoSugerido.toString();
                  widget.vm.setDescuento(widget.descuentoCtrl.text);
                  break;
              }
            },
          ),
        );

    Widget buildLey() => LeyField(
          controller: widget.leyCtrl,
          menu: widget.buildMenu<LeyAction>(
            icon: const Icon(Icons.help_outline),
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
                  widget.leyCtrl.text =
                      widget.sugeridos.leySugerida.toString();
                  widget.vm.setLey(widget.leyCtrl.text);
                  break;
              }
            },
          ),
        );

    Widget buildCantidad() => CantidadField(
          controller: widget.cantidadCtrl,
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
      onPressed: widget.onCalcular,
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
          Row(
            children: [
              Expanded(child: buildCantidad()),
              const SizedBox(width: 16),
              Expanded(child: button),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [Expanded(child: buildPrecioOro())],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: buildTipoCambio())],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: buildDescuento())],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: buildLey())],
          ),
          const SizedBox(height: 16),
          Row(
            children: [Expanded(child: buildCantidad())],
          ),
          const SizedBox(height: 32),
          button,
        ],
      );
    }
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
            style: Theme.of(context).textTheme.titleMedium,
          ),
        if (state.total != null)
          Text(
            'Precio total: ${soles(state.total!)}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
