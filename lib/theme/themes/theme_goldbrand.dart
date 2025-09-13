import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

final ColorScheme _goldCS =
lightColorScheme.copyWith(primary: const Color(0xFFC58E00));

final ThemeData goldBrandTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _goldCS,
  textTheme: buildTextTheme(_goldCS),

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

  // opcional: sin tintado en tarjetas/diálogos si no lo quieres
  cardTheme: const CardThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),
);