import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:toolmape/core/theme/themes/index.dart';

class ThemeProfileNotifier extends AsyncNotifier<String> {
  static const _kTheme = 'prefs.themeProfile';

  @override
  Future<String> build() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kTheme) ?? 'dark';
  }

  Future<void> setTheme(String profile) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kTheme, profile);
    state = AsyncData(profile);
  }
}

final themeProfileProvider =
    AsyncNotifierProvider<ThemeProfileNotifier, String>(
        () => ThemeProfileNotifier());

final themeModeProvider = Provider<ThemeMode>((ref) {
  final profile = ref.watch(themeProfileProvider).value ?? 'dark';
  return (profile == 'dark' || profile == 'black')
      ? ThemeMode.dark
      : ThemeMode.light;
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final profile = ref.watch(themeProfileProvider).value ?? 'dark';
  switch (profile) {
    case 'gold':
      return goldBrandTheme;
    case 'black':
      return blackTheme;
    case 'light':
      return lightTheme;
    case 'dark':
    default:
      return darkTheme;
  }
});
