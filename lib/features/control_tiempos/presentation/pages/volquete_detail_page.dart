import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';

const String _iconArrowRight = 'assets/icons/arrow_right.svg';
const String _iconTruckEmpty = 'assets/icons/truck_small.svg';
const String _iconTruckLoaded = 'assets/icons/truck_large.svg';
const Color _accentColor = Color(0xFFFF9F1C);
const Color _backgroundColor = Color(0xFF121212);
const Color _surfaceColor = Color(0xFF1E1E1E);
const Color _chipColor = Color(0xFF1C1C1C);

class VolqueteDetailPage extends StatefulWidget {
  const VolqueteDetailPage({
    super.key,
    required this.volquete,
  });

  final Volquete volquete;

  @override
  State<VolqueteDetailPage> createState() => _VolqueteDetailPageState();
}

class _VolqueteDetailPageState extends State<VolqueteDetailPage>
    with SingleTickerProviderStateMixin {
  late Volquete _volquete;
  late final TabController _tabController;
  late final DateFormat _dateFormat;
  Volquete? _createdVolquete;

  @override
  void initState() {
    super.initState();
    _volquete = widget.volquete;
    _tabController = TabController(length: 2, vsync: this);
    _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _editVolquete() async {
    final updated = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(
          initial: _volquete,
          defaultTipo: _volquete.tipo,
          defaultEquipo: _volquete.equipo,
          mode: VolqueteFormMode.edit,
        ),
      ),
    );

    if (updated == null) return;

    setState(() {
      _volquete = updated;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro actualizado.')),
    );
  }

  Future<void> _openQuickAdd() async {
    final created = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(
          defaultTipo: _volquete.tipo,
          defaultEquipo: _volquete.equipo,
          mode: VolqueteFormMode.quickAdd,
        ),
      ),
    );

    if (created == null) return;

    final VolqueteDescarga newDescarga = VolqueteDescarga(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      volquete: created.codigo,
      procedencia: created.procedencias.join(' / '),
      chute: created.chute,
      fechaInicio: created.inicioManiobra ?? created.llegadaFrente,
      fechaFin: created.finCarga ?? created.llegadaFrente.add(const Duration(minutes: 45)),
    );

    setState(() {
      _volquete = _volquete.copyWith(
        descargas: [newDescarga, ..._volquete.descargas],
      );
      _createdVolquete = created;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nueva carga registrada desde el detalle.')),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('¿Deseas eliminar esta carga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _popWithResult(deleted: true);
    }
  }

  void _registerInicioManiobra() {
    setState(() {
      _volquete = _volquete.copyWith(
        inicioManiobra: DateTime.now(),
        eventos: [
          ..._volquete.eventos,
          VolqueteEvento(
            titulo: 'Inicio de maniobra',
            descripcion: 'Actualizado manualmente desde el panel.',
            fecha: DateTime.now(),
            icon: VolqueteEventoIcon.arrow,
          ),
        ],
      );
    });
    _showSnack('Inicio de maniobra registrado.');
  }

  void _registerInicioCarga() {
    setState(() {
      _volquete = _volquete.copyWith(
        inicioCarga: DateTime.now(),
        eventos: [
          ..._volquete.eventos,
          VolqueteEvento(
            titulo: 'Inicio de carga',
            descripcion: 'Marcado por supervisor.',
            fecha: DateTime.now(),
            icon: VolqueteEventoIcon.truckEmpty,
          ),
        ],
      );
    });
    _showSnack('Inicio de carga registrado.');
  }

  void _registerFinCarga() {
    setState(() {
      _volquete = _volquete.copyWith(
        finCarga: DateTime.now(),
        estado: VolqueteEstado.completo,
        eventos: [
          ..._volquete.eventos,
          VolqueteEvento(
            titulo: 'Fin de carga',
            descripcion: 'Carga confirmada desde módulo de control.',
            fecha: DateTime.now(),
            icon: VolqueteEventoIcon.truckLoaded,
          ),
        ],
      );
    });
    _showSnack('Carga finalizada.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _onWillPop() async {
    _popWithResult();
    return false;
  }

  void _popWithResult({bool deleted = false}) {
    Navigator.pop(
      context,
      VolqueteDetailResult(
        updatedVolquete: deleted ? null : _volquete,
        deletedVolqueteId: deleted ? _volquete.id : null,
        createdVolquete: _createdVolquete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = Theme.of(context);
    final ThemeData themed = baseTheme.copyWith(
      scaffoldBackgroundColor: _backgroundColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: _accentColor,
        secondary: _accentColor,
        surface: _backgroundColor,
        background: _backgroundColor,
        onSurface: Colors.white,
        onPrimary: Colors.black,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: baseTheme.appBarTheme.copyWith(
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
      ),
      iconTheme: baseTheme.iconTheme.copyWith(color: Colors.white),
    );

    return Theme(
      data: themed,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: Text(_volquete.codigo),
            actions: [
              IconButton(
                onPressed: _editVolquete,
                tooltip: 'Editar registro',
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: _confirmDelete,
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: _accentColor,
            foregroundColor: Colors.black,
            onPressed: _openQuickAdd,
            child: const Icon(Icons.add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _volquete.maquinaria,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Procedencia: ${_volquete.procedencias.join(' / ')}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Chute ${_volquete.chute} • ${_dateFormat.format(_volquete.llegadaFrente)}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(estado: _volquete.estado),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryActionButton(
                            label: 'Inicio maniobra',
                            icon: SvgPicture.asset(
                              _iconArrowRight,
                              width: 32,
                              height: 32,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: _registerInicioManiobra,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PrimaryActionButton(
                            label: 'Inicio carga',
                            icon: SvgPicture.asset(
                              _iconTruckEmpty,
                              width: 32,
                              height: 32,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: _registerInicioCarga,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PrimaryActionButton(
                            label: 'Final carga',
                            icon: SvgPicture.asset(
                              _iconTruckLoaded,
                              width: 32,
                              height: 32,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: _registerFinCarga,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white70,
                        tabs: const [
                          Tab(text: 'Carga'),
                          Tab(text: 'Descargas'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _CargaTab(volquete: _volquete, dateFormat: _dateFormat),
                            _DescargasTab(volquete: _volquete, dateFormat: _dateFormat),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _chipColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40, child: Center(child: icon)),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CargaTab extends StatelessWidget {
  const _CargaTab({required this.volquete, required this.dateFormat});

  final Volquete volquete;
  final DateFormat dateFormat;

  String _format(DateTime? date) {
    if (date == null) return '—';
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _DetailRow(label: 'Volquete', value: volquete.codigo),
        _DetailRow(label: 'Maquinaria', value: volquete.maquinaria),
        _DetailRow(
          label: 'Procedencia',
          value: volquete.procedencias.join(' / '),
        ),
        _DetailRow(label: 'Chute', value: 'Chute ${volquete.chute}'),
        _DetailRow(
          label: 'Llegada a frente',
          value: dateFormat.format(volquete.llegadaFrente),
        ),
        _DetailRow(
          label: 'Inicio maniobra',
          value: _format(volquete.inicioManiobra),
        ),
        _DetailRow(
          label: 'Inicio carga',
          value: _format(volquete.inicioCarga),
        ),
        _DetailRow(
          label: 'Fin carga',
          value: _format(volquete.finCarga),
        ),
        const SizedBox(height: 12),
        if (volquete.notas != null && volquete.notas!.isNotEmpty)
          _DetailRow(label: 'Observaciones', value: volquete.notas!),
        const SizedBox(height: 24),
        Text(
          'Descargas relacionadas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _DescargasTable(volquete: volquete, dateFormat: dateFormat),
        const SizedBox(height: 24),
        if (volquete.eventos.isNotEmpty) ...[
          Text(
            'Línea de tiempo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...volquete.eventos.map(
            (evento) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _TimelineTile(evento: evento, dateFormat: dateFormat),
            ),
          ),
        ],
      ],
    );
  }
}

class _DescargasTab extends StatelessWidget {
  const _DescargasTab({required this.volquete, required this.dateFormat});

  final Volquete volquete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (volquete.descargas.isEmpty) {
      return const Center(
        child: Text('Sin descargas registradas', style: TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: volquete.descargas.length,
      itemBuilder: (_, index) {
        final descarga = volquete.descargas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _chipColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                descarga.volquete,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text('Procedencia: ${descarga.procedencia}',
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('Chute ${descarga.chute}',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 4),
              Text(
                '${dateFormat.format(descarga.fechaInicio)} – ${dateFormat.format(descarga.fechaFin)}',
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DescargasTable extends StatelessWidget {
  const _DescargasTable({required this.volquete, required this.dateFormat});

  final Volquete volquete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (volquete.descargas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _chipColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No existen descargas vinculadas a este registro.',
          style: TextStyle(color: Colors.white60),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(Colors.white10),
        columns: const [
          DataColumn(label: Text('Volquete')),
          DataColumn(label: Text('Procedencia')),
          DataColumn(label: Text('Chute')),
          DataColumn(label: Text('Fechas')),
        ],
        rows: volquete.descargas
            .map(
              (descarga) => DataRow(
                cells: [
                  DataCell(Text(descarga.volquete)),
                  DataCell(Text(descarga.procedencia)),
                  DataCell(Text(descarga.chute.toString())),
                  DataCell(
                    Text(
                      '${dateFormat.format(descarga.fechaInicio)}\n${dateFormat.format(descarga.fechaFin)}',
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.evento, required this.dateFormat});

  final VolqueteEvento evento;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineIcon(icon: evento.icon),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.titulo,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(evento.fecha),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(evento.descripcion),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineIcon extends StatelessWidget {
  const _TimelineIcon({required this.icon});

  final VolqueteEventoIcon icon;

  @override
  Widget build(BuildContext context) {
    final String? asset = icon.assetPath;
    final String? emoji = icon.emojiSymbol;

    if (asset != null || (emoji != null && emoji.isNotEmpty)) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        alignment: Alignment.center,
        child: asset != null
            ? SvgPicture.asset(
                asset,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              )
            : Text(
                emoji!,
                style: const TextStyle(fontSize: 20),
              ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: _accentColor,
      ),
    );
  }
}

extension on VolqueteEventoIcon {
  String? get assetPath {
    switch (this) {
      case VolqueteEventoIcon.arrow:
        return 'assets/icons/arrow_right.svg';
      case VolqueteEventoIcon.truckEmpty:
        return 'assets/icons/truck_small.svg';
      case VolqueteEventoIcon.truckLoaded:
        return 'assets/icons/truck_large.svg';
      case VolqueteEventoIcon.pencil:
        return 'assets/icons/edit_pen.svg';
      case VolqueteEventoIcon.clock:
      case VolqueteEventoIcon.generic:
        return null;
    }
  }

  String? get emojiSymbol {
    switch (this) {
      case VolqueteEventoIcon.arrow:
        return '→';
      case VolqueteEventoIcon.truckEmpty:
        return '🚚';
      case VolqueteEventoIcon.truckLoaded:
        return '🚛';
      case VolqueteEventoIcon.clock:
        return '⏱️';
      case VolqueteEventoIcon.pencil:
        return '✏️';
      case VolqueteEventoIcon.generic:
        return null;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.estado});

  final VolqueteEstado estado;

  @override
  Widget build(BuildContext context) {
    final bool completo = estado == VolqueteEstado.completo;
    final Color background = completo
        ? const Color(0xFF1B5E20)
        : _accentColor.withOpacity(0.25);
    final Color textColor = completo ? const Color(0xFFBBF7D0) : _accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: textColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            estado.label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class VolqueteDetailResult {
  const VolqueteDetailResult({
    this.updatedVolquete,
    this.deletedVolqueteId,
    this.createdVolquete,
  });

  final Volquete? updatedVolquete;
  final String? deletedVolqueteId;
  final Volquete? createdVolquete;
}
