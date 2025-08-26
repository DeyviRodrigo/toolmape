import 'package:flutter/material.dart';

import '../controllers/calendario_controller.dart';

/// Displays a dialog to create a new personal event.
Future<bool?> showNuevoEventoDialog(
  BuildContext context,
  CalendarioController controller,
) {
  final titulo = TextEditingController();
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nuevo evento'),
      content: TextField(
        controller: titulo,
        decoration: const InputDecoration(labelText: 'Título'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (titulo.text.trim().isEmpty) return;
            await controller.crearEvento(
              titulo: titulo.text.trim(),
              inicio: DateTime.now(),
              fin: null,
              allDay: true,
            );
            if (ctx.mounted) Navigator.pop(ctx, true);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}
