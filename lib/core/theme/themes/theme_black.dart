import 'package:flutter/material.dart';

import 'package:toolmape/core/theme/tokens/color_schemes.dart';
import 'package:toolmape/core/theme/tokens/typography.dart';
import 'package:toolmape/core/theme/extensions/app_colors.dart';
import 'package:toolmape/core/theme/tokens/shapes.dart';

// Opcional: asegura onSurface blanco (útil para fondos de icono en dark/black).
final _cs = blackColorScheme.copyWith(
  onSurface: Colors.white,
);

final ThemeData blackTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _cs,
  textTheme: buildTextTheme(_cs),

  // Fondo principal full negro
  scaffoldBackgroundColor: Colors.black,

  // Evita tinte por elevación y surfaceTint (que dan el “azulado”)
  applyElevationOverlayColor: false,
  cardTheme: const CardThemeData(
    shape: shapeMd,
    color: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    shape: shapeMd,
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1C1C1C), // puedes usar Colors.black si lo quieres más negro
    surfaceTintColor: Colors.transparent,
  ),

  // Extensiones
  extensions: const [
    AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
  ],

  // Botones blanco/negro
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      side: const WidgetStatePropertyAll(BorderSide(color: Colors.black)),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.white),
      foregroundColor: const WidgetStatePropertyAll(Colors.black),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: borderRadiusMd),
  ),

  // Divider gris medio
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade600,
    thickness: 1,
    space: 1,
  ),

  iconTheme: const IconThemeData(color: Colors.white),
  listTileTheme: const ListTileThemeData(iconColor: Colors.white, textColor: Colors.white),
);