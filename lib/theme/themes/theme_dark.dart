import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';
import '../tokens/shapes.dart';

// Ajuste del ColorScheme oscuro
final ColorScheme _darkCS = darkColorScheme.copyWith(
  primary: Colors.white,     // blanco en oscuro
  onPrimary: Colors.black,   // texto/icono sobre primary
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _darkCS,
  textTheme: buildTextTheme(_darkCS),

  extensions: const [
    AppColors(success: Color(0xFF34D399), warning: Color(0xFFFBBF24)),
  ],

  // Botón "relleno" (FilledButton) -> blanco en oscuro
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(_darkCS.primary),
      foregroundColor: MaterialStatePropertyAll(_darkCS.onPrimary),
      shape: const MaterialStatePropertyAll(shapeMd),
    ),
  ),

  // Botón "elevado" (ElevatedButton) -> blanco en oscuro
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(_darkCS.primary),
      foregroundColor: MaterialStatePropertyAll(_darkCS.onPrimary),
      shape: const MaterialStatePropertyAll(shapeMd),
    ),
  ),

  // Mantengo shape; colores heredan del esquema
  outlinedButtonTheme: const OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStatePropertyAll(shapeMd),
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: borderRadiusMd),
  ),

  // Tarjetas y diálogos igual que antes
  cardTheme: const CardThemeData(shape: shapeMd),
  dialogTheme: const DialogThemeData(shape: shapeMd),

  // Divider gris medio en oscuro
  dividerTheme: DividerThemeData(
    color: Colors.grey.shade600,
    thickness: 1,
    space: 1,
  ),

  // Iconos por defecto blancos
  iconTheme: const IconThemeData(color: Colors.white),
);
