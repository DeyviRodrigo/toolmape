import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:toolmape/features/calendar/infrastructure/services/notifications.dart';
import 'package:toolmape/features/calculator/presentation/pages/calculadora_page.dart';
import 'package:toolmape/features/calendar/presentation/pages/calendario_page.dart';
import 'package:toolmape/features/general/presentation/pages/splash_page.dart';
import 'package:toolmape/features/general/presentation/pages/informacion_page.dart';
import 'package:toolmape/app/router/routes.dart';
import 'package:toolmape/core/theme/theme_provider.dart';
import 'package:toolmape/core/theme/themes/index.dart';
import 'package:toolmape/app/di/di.dart';

String readEnv(String k, {String def = ''}) {
  // ignore: unused_local_variable
  const fromDefine = String.fromEnvironment('', defaultValue: '');
  // Workaround porque String.fromEnvironment requiere const clave:
  // Implementa lectura directa de dotenv + posibilidad de extensión futura.
  return dotenv.env[k] ?? def;
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO: integrar Sentry/Crashlytics en el futuro (no activar ahora)
  };

  // .env (no detiene si falta)
  try { await dotenv.load(fileName: ".env"); } catch (_) {}

  // Supabase si hay claves válidas
  final supaUrl = readEnv('SUPABASE_URL');
  final supaKey = readEnv('SUPABASE_ANON_KEY');
  if (supaUrl.isNotEmpty && supaKey.isNotEmpty) {
    try {
      await Supabase.initialize(url: supaUrl, anonKey: supaKey);
      final supa = Supabase.instance.client;
      if (supa.auth.currentUser == null) {
        try { await supa.auth.signInAnonymously(); } catch (error) {
          debugPrint('Supabase anonymous login failed: $error');
        }
      }
    } catch (error) {
      debugPrint('Supabase initialization failed: $error');
    }
  }

  // Notificaciones locales (no web)
  if (!kIsWeb) {
    try {
      await CalendarioNotifications.init();
    } catch (error) {
      debugPrint('CalendarioNotifications initialization failed: $error');
    }
  }

  await initDependencies();

  runApp(
    const ProviderScope(
      // observers: [],
      child: ToolMAPEApp(),
    ),
  );
}

class ToolMAPEApp extends ConsumerWidget {
  const ToolMAPEApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeDataProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToolMAPE',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: mode,
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
      initialRoute: routeSplash,
      routes: {
        routeSplash: (_) => const SplashPage(),
        routeCalculadora: (_) => const CalculadoraPage(),
        routeCalendario: (_) => const CalendarioPage(),
        routeInformacion: (_) => const InformacionPage(),
      },
    );
  }
}
