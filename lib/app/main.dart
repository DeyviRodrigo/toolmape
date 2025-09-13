import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:toolmape/features/calendar/infrastructure/services/notifications.dart';
import 'package:toolmape/features/calculator/presentation/pages/calculadora_page.dart';
import 'package:toolmape/features/calendar/presentation/pages/calendario_page.dart';
import 'package:toolmape/features/general/presentation/pages/splash_page.dart';
import 'package:toolmape/app/routes.dart';
import 'package:toolmape/theme/theme_provider.dart';
import 'package:toolmape/theme/themes/index.dart';

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

  runApp(const ProviderScope(child: ToolMAPEApp()));
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
      },
    );
  }
}
