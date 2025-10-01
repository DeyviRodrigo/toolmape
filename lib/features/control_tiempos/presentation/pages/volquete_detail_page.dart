import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:toolmape/features/control_tiempos/domain/entities/volquete.dart';
import 'package:toolmape/features/control_tiempos/presentation/pages/volquete_form_page.dart';

class VolqueteDetailPage extends StatelessWidget {
  VolqueteDetailPage({
    super.key,
    required this.volquete,
  }) : _dateFormat = DateFormat('dd/MM/yyyy – HH:mm');

  final Volquete volquete;
  final DateFormat _dateFormat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(volquete.codigo),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderSection(volquete: volquete, dateFormat: _dateFormat),
              const SizedBox(height: 24),
              _TimelineSection(volquete: volquete, dateFormat: _dateFormat),
              const SizedBox(height: 24),
              _ActionsSection(volquete: volquete),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.volquete,
    required this.dateFormat,
  });

  final Volquete volquete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              volquete.codigo,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoChip(
                  icon: Icons.badge_outlined,
                  label: 'Operador',
                  value: volquete.operador,
                ),
                _InfoChip(
                  icon: Icons.tag_outlined,
                  label: 'Placa',
                  value: volquete.placa,
                ),
                _InfoChip(
                  icon: Icons.route_outlined,
                  label: 'Destino',
                  value: volquete.destino,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatusIndicator(estado: volquete.estado),
                const SizedBox(width: 16),
                Text(
                  dateFormat.format(volquete.fecha),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (volquete.notas != null && volquete.notas!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                volquete.notas!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({
    required this.volquete,
    required this.dateFormat,
  });

  final Volquete volquete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Línea de tiempo',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: volquete.eventos.length,
          separatorBuilder: (_, __) => const Divider(height: 24),
          itemBuilder: (_, index) {
            final evento = volquete.eventos[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != volquete.eventos.length - 1)
                      Container(
                        width: 2,
                        height: 48,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento.titulo,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(evento.fecha),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        evento.descripcion,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({required this.volquete});

  final Volquete volquete;

  Future<void> _onEditar(BuildContext context) async {
    final updated = await Navigator.push<Volquete>(
      context,
      MaterialPageRoute(
        builder: (_) => VolqueteFormPage(initial: volquete),
      ),
    );

    if (updated == null) return;
    Navigator.pop(
      context,
      VolqueteDetailResult(updatedVolquete: updated),
    );
  }

  Future<void> _onEliminar(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar volquete'),
        content: const Text('¿Deseas eliminar el registro seleccionado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.pop(
        context,
        VolqueteDetailResult(deletedVolqueteId: volquete.id),
      );
    }
  }

  void _onCompartir(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enlace compartido en portapapeles.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _onEditar(context),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
            OutlinedButton.icon(
              onPressed: () => _onEliminar(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
            OutlinedButton.icon(
              onPressed: () => _onCompartir(context),
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('Compartir'),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.estado});

  final VolqueteEstado estado;

  Color _color(BuildContext context) {
    switch (estado) {
      case VolqueteEstado.completo:
        return Colors.green.shade600;
      case VolqueteEstado.enProceso:
        return Colors.orange.shade600;
      case VolqueteEstado.pausado:
        return Colors.blueGrey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: _color(context).withOpacity(0.15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _color(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            estado.label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: _color(context), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.primary),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
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
  });

  final Volquete? updatedVolquete;
  final String? deletedVolqueteId;
}
