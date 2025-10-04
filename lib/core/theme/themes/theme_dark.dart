import 'package:flutter/material.dart';
import 'package:toolmape/core/theme/tokens/color_schemes.dart';
import 'package:toolmape/core/theme/tokens/typography.dart';
import 'package:toolmape/core/theme/extensions/app_colors.dart';
import 'package:toolmape/core/theme/tokens/shapes.dart';

final ColorScheme _darkCS = darkColorScheme;

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

  // Botón "relleno" (FilledButton) -> usa el primario del esquema oscuro
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(_darkCS.primary),
      foregroundColor: WidgetStatePropertyAll(_darkCS.onPrimary),
      shape: const WidgetStatePropertyAll(shapeMd),
    ),
  ),

  // Botón "elevado" (ElevatedButton) -> usa el primario del esquema oscuro
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

  // Iconos usando el color onSurface del esquema oscuro
  iconTheme: IconThemeData(color: _darkCS.onSurface),
  scaffoldBackgroundColor: _darkCS.background,
  canvasColor: _darkCS.surface,
  drawerTheme: DrawerThemeData(
    backgroundColor: _darkCS.surface,
    surfaceTintColor: Colors.transparent,
  ),
);
