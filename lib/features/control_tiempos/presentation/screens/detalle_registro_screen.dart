import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/models/registro_tiempo.dart';
import 'package:toolmape/features/control_tiempos/presentation/controllers/control_tiempos_controller.dart';
import 'package:toolmape/features/control_tiempos/presentation/screens/formulario_registro_screen.dart';
import 'package:toolmape/theme/app_colors.dart';

class DetalleRegistroScreen extends ConsumerWidget {
  DetalleRegistroScreen({super.key, required this.registroId})
      : _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  final String registroId;
  final DateFormat _dateFormat;

  RegistroTiempo? _findRegistro(ControlTiemposState state) {
    try {
      return state.registros.firstWhere((registro) => registro.id == registroId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onEditar(
    BuildContext context,
    WidgetRef ref,
    RegistroTiempo registro,
  ) async {
    final state = ref.read(controlTiemposControllerProvider);
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioRegistroScreen(
          modo: RegistroModo.edicion,
          registro: registro,
          equipoTipo: state.equipoActual,
          operacion: state.operacion,
        ),
      ),
    );
    if (shouldRefresh == true) {
      await ref.read(controlTiemposControllerProvider.notifier).cargar();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro actualizado.')),
        );
      }
    }
  }

  Future<void> _onEliminar(
    BuildContext context,
    WidgetRef ref,
    RegistroTiempo registro,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Deseas eliminar ${registro.volquete}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(controlTiemposControllerProvider.notifier)
          .eliminar(registro.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro eliminado.')),
        );
      }
    }
  }

  void _onCompartir(BuildContext context, RegistroTiempo registro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compartiendo ${registro.volquete}…')),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'En proceso';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) {
      return '$minutes min';
    }
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(controlTiemposControllerProvider);
    final registro = _findRegistro(state);

    if (registro == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Registro no encontrado'),
          backgroundColor: AppColors.surface,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            'No encontramos la información solicitada.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(registro.volquete),
        backgroundColor: AppColors.surface,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _onEditar(context, ref, registro),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _onEliminar(context, ref, registro),
          ),
          IconButton(
            tooltip: 'Compartir',
            icon: const Icon(Icons.ios_share_outlined),
            onPressed: () => _onCompartir(context, registro),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(registro: registro, dateFormat: _dateFormat),
            const SizedBox(height: 24),
            _InfoGeneralSection(registro: registro, formatDuration: _formatDuration),
            const SizedBox(height: 24),
            _TimelineSection(registro: registro, dateFormat: _dateFormat),
            const SizedBox(height: 24),
            _ObservacionesSection(observaciones: registro.observaciones),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.registro, required this.dateFormat});

  final RegistroTiempo registro;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
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
                      registro.volquete,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      registro.operador,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              _EstadoChip(estado: registro.estado),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(registro.fechaInicio),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoGeneralSection extends StatelessWidget {
  const _InfoGeneralSection({
    required this.registro,
    required this.formatDuration,
  });

  final RegistroTiempo registro;
  final String Function(Duration?) formatDuration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información general',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Operador',
                value: registro.operador,
              ),
              _InfoTile(
                icon: Icons.route_outlined,
                label: 'Destino',
                value: registro.destino,
              ),
              _InfoTile(
                icon: Icons.timer_outlined,
                label: 'Duración',
                value: formatDuration(registro.duracion),
              ),
              _InfoTile(
                icon: Icons.category_outlined,
                label: 'Equipo',
                value: registro.equipo.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.registro, required this.dateFormat});

  final RegistroTiempo registro;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Línea de tiempo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final actividad = registro.actividades[index];
              final isLast = index == registro.actividades.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 48,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: AppColors.primary.withOpacity(0.4),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividad.nombre,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(actividad.fecha),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          actividad.descripcion,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemCount: registro.actividades.length,
          ),
        ],
      ),
    );
  }
}

class _ObservacionesSection extends StatelessWidget {
  const _ObservacionesSection({required this.observaciones});

  final String? observaciones;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Observaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            observaciones?.isNotEmpty == true
                ? observaciones!
                : 'Sin observaciones registradas.',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  const _EstadoChip({required this.estado});

  final RegistroEstado estado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: estado.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        estado.label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
