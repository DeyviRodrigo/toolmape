import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'typography.dart';

ThemeData buildLightTheme() {
  final cs = lightColorScheme;
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: buildTextTheme(cs),
    extensions: const [
      AppColors(success: Color(0xFF10B981), warning: Color(0xFFF59E0B)),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surface,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: buildTextTheme(cs).labelLarge,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: cs.surface,
      scrimColor: cs.onSurface.withOpacity(0.54),
    ),
    iconTheme: IconThemeData(color: cs.onSurface),
    primaryIconTheme: IconThemeData(color: cs.primary),
    dividerTheme: DividerThemeData(color: cs.outline),
  );
}

ThemeData buildDarkTheme() {
  final cs = darkColorScheme;
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    textTheme: buildTextTheme(cs),
    extensions: const [
      AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surface,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: buildTextTheme(cs).labelLarge,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: cs.surface,
      scrimColor: cs.onSurface.withOpacity(0.54),
    ),
    iconTheme: IconThemeData(color: cs.onSurface),
    primaryIconTheme: IconThemeData(color: cs.primary),
    dividerTheme: DividerThemeData(color: cs.outline),
  );
}
