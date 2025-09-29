import 'package:flutter/material.dart';

import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/app/shell/app_shell.dart';

/// Página: InformacionPage - comparte detalles generales del aplicativo.
class InformacionPage extends StatelessWidget {
  const InformacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildFeature({
      required IconData icon,
      required String title,
      required String description,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AppShell(
      title: 'Información de la app',
      onGoToCalculadora: () =>
          Navigator.pushReplacementNamed(context, routeCalculadora),
      onGoToCalendario: () =>
          Navigator.pushReplacementNamed(context, routeCalendario),
      onGoToControlTiempos: () =>
          Navigator.pushReplacementNamed(context, routeControlTiempos),
      onGoToInformacion: () =>
          Navigator.pushReplacementNamed(context, routeInformacion),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ToolMAPE es una aplicación digital diseñada para apoyar a las pequeñas y '
              'medianas empresas mineras en la gestión de información clave, el control '
              'de procesos y la toma de decisiones estratégicas. Su objetivo es brindar '
              'herramientas simples, seguras y actualizadas para mejorar la trazabilidad, '
              'la productividad y la sostenibilidad de la minería en pequeña escala.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              '📌 Funcionalidades principales',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildFeature(
              icon: Icons.calculate_outlined,
              title: 'Calcular precio del oro',
              description:
                  'Permite estimar el valor real del oro de acuerdo a la ley (%) y peso, '
                  'mostrando resultados en moneda local y extranjera. Los cálculos se basan '
                  'en fuentes de precios internacionales actualizadas.',
            ),
            buildFeature(
              icon: Icons.calendar_month,
              title: 'Calendario minero',
              description:
                  'Agenda de actividades, eventos y plazos importantes del sector minero, '
                  'configurable por el usuario.',
            ),
            buildFeature(
              icon: Icons.bar_chart,
              title: 'Análisis del oro',
              description:
                  'Gráficas y reportes de tendencias históricas y actuales del precio del '
                  'oro, en distintos rangos de tiempo y monedas.',
            ),
            buildFeature(
              icon: Icons.menu_book_outlined,
              title: 'Biblioteca minera',
              description:
                  'Repositorio con normativa, manuales, guías y documentos técnicos útiles '
                  'para la operación y la gestión minera.',
            ),
            buildFeature(
              icon: Icons.support_agent,
              title: 'Consultoría personalizada',
              description:
                  'Canal de contacto para acceder a asesoría especializada en trazabilidad, '
                  'gestión ambiental y mejora de procesos.',
            ),
            const SizedBox(height: 8),
            Text(
              'Propósito',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'ToolMAPE busca digitalizar la experiencia minera, ofreciendo un espacio '
              'integrado donde se unan cálculos, análisis y asesoría en un solo '
              'aplicativo, facilitando la toma de decisiones y el cumplimiento '
              'normativo.',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
