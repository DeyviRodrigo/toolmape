import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController();
});

class ThemeController extends ChangeNotifier {
  static const _prefKey = 'theme_mode';
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_prefKey);
    if (index != null && index >= 0 && index < ThemeMode.values.length) {
      themeMode = ThemeMode.values[index];
    }
    // Notificar para que MaterialApp recoja el valor cargado si se crea luego
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, mode.index);
    notifyListeners();
  }

  Future<void> toggle() async {
    final newMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}