import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  textTheme: buildTextTheme(darkColorScheme),
  extensions: const [
    AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
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
