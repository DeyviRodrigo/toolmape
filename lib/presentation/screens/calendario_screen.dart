import 'package:flutter/material.dart';

import '../controllers/calendario_controller.dart';
import '../widgets/nuevo_evento_dialog.dart';

/// Stateless calendar screen that delegates actions to a controller.
class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key, required this.controller});

  final CalendarioController controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.eventosDelMes(DateTime.now()),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Scaffold(
          appBar: AppBar(title: const Text('Calendario')),
          body: Center(child: Text('Eventos este mes: $count')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => showNuevoEventoDialog(context, controller),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
