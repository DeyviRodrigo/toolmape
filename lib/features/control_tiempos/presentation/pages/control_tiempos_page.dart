import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/features/control_tiempos/domain/entities/descarga_registro.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/descarga_detail_page.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/descarga_form_page.dart';

const String _iconTruckFull = '🚛';
const String _iconTruckEmpty = '🚚';
const String _iconArrow = '➡️';
const String _iconPencil = '✏️';

const Color _backgroundColor = Color(0xFF121212);
const Color _cardColor = Color(0xFF1E1E1E);
const Color _accentColor = Color(0xFFFF9F1C);
const Color _textSecondary = Color(0xFF9CA3AF);

enum _DescargaFiltro { todos, completo, incompleto }

extension on _DescargaFiltro {
  String get label {
    switch (this) {
      case _DescargaFiltro.todos:
        return 'Todos';
      case _DescargaFiltro.completo:
        return 'Completos';
      case _DescargaFiltro.incompleto:
        return 'Incompletos';
    }
  }
}

class ControlTiemposPage extends StatefulWidget {
  const ControlTiemposPage({super.key});

  @override
  State<ControlTiemposPage> createState() => _ControlTiemposPageState();
}

class _ControlTiemposPageState extends State<ControlTiemposPage> {
  late List<DescargaRegistro> _registros;
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  _DescargaFiltro _estadoFiltro = _DescargaFiltro.todos;
  String _searchTerm = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _registros = List<DescargaRegistro>.from(kDescargasDemo);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchTerm = value.trim().toLowerCase();
      });
    });
  }

  void _onRefresh() {
    setState(() {
      _registros = List<DescargaRegistro>.from(kDescargasDemo);
      _searchTerm = '';
      _estadoFiltro = _DescargaFiltro.todos;
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registros sincronizados')),
    );
  }

  List<DescargaRegistro> get _filteredRegistros {
    final List<DescargaRegistro> filtered = _registros.where((registro) {
      final matchesSearch = _searchTerm.isEmpty ||
          registro.volquete.toLowerCase().contains(_searchTerm) ||
          registro.procedencia.toLowerCase().contains(_searchTerm) ||
          registro.volqueteAlias.toLowerCase().contains(_searchTerm);

      if (!matchesSearch) return false;

      switch (_estadoFiltro) {
        case _DescargaFiltro.todos:
          return true;
        case _DescargaFiltro.completo:
          return registro.estado == DescargaEstado.completo;
        case _DescargaFiltro.incompleto:
          return registro.estado == DescargaEstado.incompleto;
      }
    }).toList();

    filtered.sort((a, b) => b.llegadaChute.compareTo(a.llegadaChute));
    return filtered;
  }

  Future<void> _openAddForm() async {
    final DescargaRegistro? result = await Navigator.push<DescargaRegistro>(
      context,
      MaterialPageRoute(
        builder: (_) => const DescargaFormPage(
          mode: DescargaFormMode.create,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _registros = List<DescargaRegistro>.from(_registros)..add(result);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga registrada')),
    );
  }

  Future<void> _openEditForm(DescargaRegistro registro) async {
    final DescargaRegistro? result = await Navigator.push<DescargaRegistro>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaFormPage(
          mode: DescargaFormMode.edit,
          initial: registro,
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      final List<DescargaRegistro> updated = List<DescargaRegistro>.from(_registros);
      final index = updated.indexWhere((element) => element.id == registro.id);
      if (index >= 0) {
        updated[index] = result;
      } else {
        updated.add(result);
      }
      _registros = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Descarga actualizada')),
    );
  }

  Future<void> _openDetail(DescargaRegistro registro) async {
    final List<DescargaRegistro>? updated = await Navigator.push<List<DescargaRegistro>>(
      context,
      MaterialPageRoute(
        builder: (_) => DescargaDetailPage(
          registro: registro,
          registros: List<DescargaRegistro>.from(_registros),
        ),
      ),
    );

    if (updated == null) return;

    setState(() {
      _registros = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: _backgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: scheme.copyWith(
          primary: _accentColor,
          secondary: _accentColor,
        ),
      ),
      child: AppShell(
        title: 'Control de tiempos',
        onGoToCalculadora: () => Navigator.pushReplacementNamed(context, routeCalculadora),
        onGoToCalendario: () => Navigator.pushReplacementNamed(context, routeCalendario),
        onGoToControlTiempos: () => Navigator.pushReplacementNamed(context, routeControlTiempos),
        onGoToInformacion: () => Navigator.pushReplacementNamed(context, routeInformacion),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accentColor,
        onPressed: _openAddForm,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        child: Container(
          color: _backgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: _BottomToggleButton(
                  label: 'Carga',
                  isActive: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vista de carga en desarrollo')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: _BottomToggleButton(
                  label: 'Descarga',
                  isActive: true,
                ),
              ),
            ],
          ),
        ),
      ),
        body: Container(
          color: _backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopActionsBar(
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    filtro: _estadoFiltro,
                    onFiltroChanged: (value) {
                      setState(() {
                        _estadoFiltro = value;
                      });
                    },
                    onRefresh: _onRefresh,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredRegistros.isEmpty
                        ? const _EmptyRegistrosView()
                        : ListView.separated(
                            itemCount: _filteredRegistros.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final registro = _filteredRegistros[index];
                              return _DescargaListTile(
                                registro: registro,
                                dateFormat: _dateFormat,
                                timeFormat: _timeFormat,
                                onTap: () => _openDetail(registro),
                                onInicioDescarga: () => _showActionSnack('Inicio de descarga registrado'),
                                onFinDescarga: () => _showActionSnack('Final de descarga registrado'),
                                onSalidaChute: () => _showActionSnack('Salida de chute registrada'),
                                onEdit: () => _openEditForm(registro),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showActionSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _TopActionsBar extends StatelessWidget {
  const _TopActionsBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.filtro,
    required this.onFiltroChanged,
    required this.onRefresh,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final _DescargaFiltro filtro;
  final ValueChanged<_DescargaFiltro> onFiltroChanged;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.white70),
                hintText: 'Buscar volquete...',
                hintStyle: TextStyle(color: _textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<_DescargaFiltro>(
              value: filtro,
              onChanged: (value) {
                if (value != null) {
                  onFiltroChanged(value);
                }
              },
              dropdownColor: _cardColor,
              iconEnabledColor: Colors.white,
              underline: const SizedBox.shrink(),
              style: const TextStyle(color: Colors.white),
              items: _DescargaFiltro.values
                  .map(
                    (value) => DropdownMenuItem<_DescargaFiltro>(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Refrescar',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: _accentColor),
          ),
        ),
      ],
    );
  }
}

class _DescargaListTile extends StatelessWidget {
  const _DescargaListTile({
    required this.registro,
    required this.dateFormat,
    required this.timeFormat,
    required this.onTap,
    required this.onInicioDescarga,
    required this.onFinDescarga,
    required this.onSalidaChute,
    required this.onEdit,
  });

  final DescargaRegistro registro;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final VoidCallback onTap;
  final VoidCallback onInicioDescarga;
  final VoidCallback onFinDescarga;
  final VoidCallback onSalidaChute;
  final VoidCallback onEdit;

  Color get _estadoColor =>
      registro.estado == DescargaEstado.completo ? const Color(0xFF1DB954) : _accentColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registro.volquete,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateFormat.format(registro.llegadaChute),
                    style: const TextStyle(color: _textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Procedencia: ${registro.procedencia}',
                    style: const TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                  if (registro.inicioDescarga != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniTimeBadge(label: 'Inicio', time: timeFormat.format(registro.inicioDescarga!)),
                        const SizedBox(width: 8),
                        if (registro.finalDescarga != null)
                          _MiniTimeBadge(label: 'Fin', time: timeFormat.format(registro.finalDescarga!)),
                        const SizedBox(width: 8),
                        if (registro.salidaChute != null)
                          _MiniTimeBadge(label: 'Salida', time: timeFormat.format(registro.salidaChute!)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  registro.estado.label,
                  style: TextStyle(
                    color: _estadoColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EmojiActionButton(emoji: _iconTruckFull, onTap: onInicioDescarga),
                    const SizedBox(width: 8),
                    _EmojiActionButton(emoji: _iconTruckEmpty, onTap: onFinDescarga),
                    const SizedBox(width: 8),
                    _EmojiActionButton(emoji: _iconArrow, onTap: onSalidaChute),
                    const SizedBox(width: 8),
                    _EmojiActionButton(emoji: _iconPencil, onTap: onEdit),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTimeBadge extends StatelessWidget {
  const _MiniTimeBadge({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label · $time',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}

class _EmojiActionButton extends StatelessWidget {
  const _EmojiActionButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _BottomToggleButton extends StatelessWidget {
  const _BottomToggleButton({
    required this.label,
    required this.isActive,
    this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = isActive ? _accentColor : _cardColor;
    final Color textColor = isActive ? Colors.black : Colors.white;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyRegistrosView extends StatelessWidget {
  const _EmptyRegistrosView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inventory_2_outlined, color: _textSecondary, size: 56),
          SizedBox(height: 12),
          Text(
            'Sin registros que coincidan con la búsqueda',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
