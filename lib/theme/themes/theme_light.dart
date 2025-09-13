import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  textTheme: buildTextTheme(lightColorScheme),

  extensions: const [
    AppColors(success: Color(0xFF10B981), warning: Color(0xFFF59E0B)),
  ],

  filledButtonTheme: FilledButtonThemeData(
    style: const ButtonStyle(
      shape: WidgetStatePropertyAll(shapeMd),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: const ButtonStyle(
      shape: WidgetStatePropertyAll(shapeMd),
    ),
  ),
  outlinedButtonTheme: const OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(shapeMd),
    ),
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(shapeMd),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: borderRadiusMd),
  ),

  cardTheme: const CardThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),
);