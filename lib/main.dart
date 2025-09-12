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
import 'core_foundation/core_foundation.dart';

/// Función: main - punto de entrada de la aplicación.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Cargar variables de entorno (.env). No detiene la app si no existe.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Ignorar si el asset no está disponible (p. ej., en web sin .env)
  }

  // 2) Inicializar Supabase solo si hay claves válidas.
  final supaUrl = dotenv.env['SUPABASE_URL'];
  final supaKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supaUrl != null &&
      supaKey != null &&
      supaUrl.isNotEmpty &&
      supaKey.isNotEmpty) {
    await Supabase.initialize(url: supaUrl, anonKey: supaKey);

    // 2.1) Asegurar sesión anónima para poder guardar eventos privados por usuario.
    final supa = Supabase.instance.client;
    if (supa.auth.currentUser == null) {
      try {
        await supa.auth.signInAnonymously();
      } catch (_) {
        // Si falla, la app igual arranca; solo afectará guardar eventos privados.
      }
    }
  }

  // 3) Notificaciones locales: NO en web (el plugin no está soportado).
  if (!kIsWeb) {
    await CalendarioNotifications.init();
  }

  runApp(const ProviderScope(child: ToolMAPEApp()));
}

/// Widget: ToolMAPEApp - configuración base de MaterialApp.
class ToolMAPEApp extends StatelessWidget {
  const ToolMAPEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToolMAPE',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFFFC107),
        extensions: const [ToolmapeTheme(brandGold: Color(0xFFFFC107))],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFC107),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        drawerTheme: DrawerThemeData(backgroundColor: Colors.grey.shade900),
        extensions: const [ToolmapeTheme(brandGold: Color(0xFFFFC107))],
      ),
      themeMode: ThemeMode.system,
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
