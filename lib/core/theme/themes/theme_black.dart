import 'package:flutter/material.dart';

import 'package:toolmape/core/theme/tokens/color_schemes.dart';
import 'package:toolmape/core/theme/tokens/typography.dart';
import 'package:toolmape/core/theme/extensions/app_colors.dart';
import 'package:toolmape/core/theme/tokens/shapes.dart';

// Opcional: asegura onSurface blanco (útil para fondos de icono en dark/black).
final _cs = blackColorScheme.copyWith(
  onSurface: Colors.white,
  surface: Colors.black,
  surfaceVariant: Colors.black,
  background: Colors.black,
  surfaceTint: Colors.transparent,
);

final ThemeData blackTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _cs,
  textTheme: buildTextTheme(_cs),

  // Fondo principal full negro
  scaffoldBackgroundColor: Colors.black,
  canvasColor: Colors.black,
  cardColor: Colors.black,
  dialogBackgroundColor: Colors.black,

  // Evita tinte por elevación y surfaceTint (que dan el “azulado”)
  applyElevationOverlayColor: false,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
  ),
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
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  navigationDrawerTheme: const NavigationDrawerThemeData(
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: Colors.black,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.black,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
  ),
  popupMenuTheme: const PopupMenuThemeData(
    color: Colors.black,
    surfaceTintColor: Colors.transparent,
    textStyle: TextStyle(color: Colors.white),
  ),
  menuBarTheme: MenuBarThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.black),
      surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(Colors.transparent),
      elevation: WidgetStatePropertyAll(0),
    ),
  ),
  menuTheme: MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.black),
      surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(Colors.transparent),
      elevation: WidgetStatePropertyAll(0),
    ),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.black),
      surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
      shadowColor: WidgetStatePropertyAll(Colors.transparent),
      elevation: WidgetStatePropertyAll(0),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.black,
      filled: true,
      border: OutlineInputBorder(borderRadius: borderRadiusMd),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.black,
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: Colors.white,
    behavior: SnackBarBehavior.floating,
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
