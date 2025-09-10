import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'themes/index.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
final themeProfileProvider = StateProvider<String>((_) => 'light');

final themeDataProvider = Provider<ThemeData>((ref) {
  switch (ref.watch(themeProfileProvider)) {
    case 'gold':
      return goldBrandTheme;
    case 'dark':
      return darkTheme;
    case 'light':
    default:
      return lightTheme;
  }
});
