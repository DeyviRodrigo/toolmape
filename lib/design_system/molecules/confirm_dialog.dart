import 'package:flutter/material.dart';

/// Muestra un diálogo de confirmación con múltiples opciones.
Future<String?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required List<String>
  options, // p.ej. ['Requiero ayuda','Utilizar predeterminado']
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: options
          .map(
            (opt) => TextButton(
              onPressed: () => Navigator.pop(context, opt),
              child: Text(opt),
            ),
          )
          .toList(),
    ),
  );
}
