import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/index.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);
final themeProfileProvider = StateProvider<String>((_) => 'dark');

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
