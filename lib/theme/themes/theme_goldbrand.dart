import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

final goldBrandTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme.copyWith(primary: const Color(0xFFC58E00)),
  textTheme: buildTextTheme(lightColorScheme),
  extensions: const [
    AppColors(success: Color(0xFF10B981), warning: Color(0xFFF59E0B)),
  ],
  filledButtonTheme: FilledButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: borderRadiusMd),
  ),
  cardTheme: const CardTheme(shape: shapeMd),
  dialogTheme: const DialogTheme(shape: shapeMd),
);
