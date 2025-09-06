import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme(ColorScheme colorScheme) {
  final base = GoogleFonts.interTextTheme();
  final titles = GoogleFonts.poppinsTextTheme();
  final merged = base.copyWith(
    displayLarge: titles.displayLarge?.copyWith(fontWeight: FontWeight.w600),
    displayMedium: titles.displayMedium?.copyWith(fontWeight: FontWeight.w600),
    displaySmall: titles.displaySmall?.copyWith(fontWeight: FontWeight.w600),
    headlineLarge: titles.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
    headlineMedium: titles.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
    headlineSmall: titles.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
    titleLarge: titles.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    titleMedium: titles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: titles.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge,
    bodyMedium: base.bodyMedium,
    bodySmall: base.bodySmall,
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500),
    labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
    labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
  );
  return merged.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );
}
