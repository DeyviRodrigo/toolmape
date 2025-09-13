import 'package:flutter/material.dart';

import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

final blackTheme = ThemeData(
  useMaterial3: true,
  colorScheme: blackColorScheme,
  textTheme: buildTextTheme(blackColorScheme),
  scaffoldBackgroundColor: Colors.black,
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1C1C1C),
  ),
  extensions: const [
    AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
  ],
  filledButtonTheme: FilledButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
      side: MaterialStatePropertyAll(BorderSide(color: Colors.black)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: const ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
      backgroundColor: MaterialStatePropertyAll(Colors.white),
      foregroundColor: MaterialStatePropertyAll(Colors.black),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: borderRadiusMd),
  ),
  cardTheme: const CardThemeData(shape: shapeMd),
  dialogTheme: const DialogThemeData(shape: shapeMd),
);
