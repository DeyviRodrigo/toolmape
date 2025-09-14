import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:toolmape/app/shell/app_shell.dart';
import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/features/general/infrastructure/services/chatgpt_service.dart';

/// Página: AnalisisPage - muestra el informe generado por GPT.
class AnalisisPage extends ConsumerStatefulWidget {
  const AnalisisPage({super.key});

  @override
  ConsumerState<AnalisisPage> createState() => _AnalisisPageState();
}

class _AnalisisPageState extends ConsumerState<AnalisisPage> {
  String? _resultado;
  bool _cargando = false;

  Future<void> _solicitar() async {
    setState(() => _cargando = true);
    try {
      final service = ref.read(chatGPTServiceProvider);
      final texto = await service.solicitarAnalisisCompraVentaOro();
      setState(() => _resultado = texto);
    } catch (e) {
      setState(() => _resultado = 'Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Análisis de oro',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      onGoToAnalisis: () =>
          Navigator.pushReplacementNamed(context, routeAnalisis),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _cargando ? null : _solicitar,
              child: const Text('Solicitar análisis'),
            ),
            const SizedBox(height: 16),
            if (_cargando) const Center(child: CircularProgressIndicator()),
            if (!_cargando && _resultado != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_resultado!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
