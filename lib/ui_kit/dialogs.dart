import 'package:flutter/material.dart';

/// Función: choiceDialog - muestra un diálogo con opciones.
Future<String?> choiceDialog({
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
