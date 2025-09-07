import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/notifications/calendario_notifications.dart';
import 'features/calculadora/calculadora_screen.dart';
import 'features/calendario/calendario_screen.dart';
import 'routes.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env (no detiene si falta)
  try { await dotenv.load(fileName: ".env"); } catch (_) {}

  // Supabase si hay claves válidas
  final supaUrl = dotenv.env['SUPABASE_URL'];
  final supaKey = dotenv.env['SUPABASE_ANON_KEY'];
  if ((supaUrl ?? '').isNotEmpty && (supaKey ?? '').isNotEmpty) {
    await Supabase.initialize(url: supaUrl!, anonKey: supaKey!);
    final supa = Supabase.instance.client;
    if (supa.auth.currentUser == null) {
      try { await supa.auth.signInAnonymously(); } catch (_) {}
    }
  }

  // Notificaciones locales (no web)
  if (!kIsWeb) {
    await CalendarioNotifications.init();
  }

  // Theme controller (persistencia)
  final themeController = ThemeController();
  await themeController.load();

  runApp(
    ProviderScope(
      overrides: [
        // ANTES: themeControllerProvider.overrideWithValue(themeController)
        themeControllerProvider.overrideWith((ref) => themeController),
      ],
      child: const ToolMAPEApp(),
    ),
  );
}

class ToolMAPEApp extends ConsumerWidget {
  const ToolMAPEApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(themeControllerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToolMAPE',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: controller.themeMode,
      locale: const Locale('es', 'PE'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'PE'),
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      initialRoute: routeCalculadora,
      routes: {
        routeCalculadora: (_) => const ScreenCalculadora(),
        routeCalendario: (_) => const CalendarioMineroScreen(),
      },
    );
  }
}
