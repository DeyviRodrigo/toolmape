import 'package:flutter/material.dart';
import 'package:toolmape/core/theme/tokens/color_schemes.dart';
import 'package:toolmape/core/theme/tokens/typography.dart';
import 'package:toolmape/core/theme/extensions/app_colors.dart';
import 'package:toolmape/core/theme/tokens/shapes.dart';

// Ajuste del ColorScheme oscuro: primary/blanco para usarlo en iconos si lo necesitas
final ColorScheme _darkCS = darkColorScheme.copyWith(
  primary: Colors.white,
  onPrimary: Colors.black,
  background: Colors.black,
  surface: Colors.black,
  surfaceVariant: Colors.black,
  // (opcional) si quieres usar onSurface como fondo blanco para el logo en dark:
  // onSurface: Colors.white,
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkCS,
  textTheme: buildTextTheme(_darkCS),

  // Evita tinte azulado por elevación en M3
  applyElevationOverlayColor: false,

  // Extensiones personalizadas
  extensions: const [
    AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
  ],

  // Botón "relleno" (FilledButton) -> fondo blanco / texto negro en oscuro
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(_darkCS.primary),
      foregroundColor: WidgetStatePropertyAll(_darkCS.onPrimary),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),

  // Botón "elevado" (ElevatedButton) -> fondo blanco / texto negro en oscuro
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(_darkCS.primary),
      foregroundColor: WidgetStatePropertyAll(_darkCS.onPrimary),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),

  // Mantengo shape; colores heredan del esquema
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

  // Superficies sin surfaceTint (para evitar azules/grises no deseados)
  cardTheme: const CardThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),
  dialogTheme: const DialogThemeData(
    shape: shapeMd,
    surfaceTintColor: Colors.transparent,
  ),

  // Divider gris medio
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade600,
    thickness: 1,
    space: 1,
  ),

  // Iconos por defecto blancos
  iconTheme: const IconThemeData(color: Colors.white),
  scaffoldBackgroundColor: Colors.black,
  canvasColor: Colors.black,
);