import 'package:flutter/material.dart';

import 'package:toolmape/core/theme/extensions/app_colors.dart';

class ControlTiemposPalette {
  const ControlTiemposPalette({
    required this.background,
    required this.surface,
    required this.outline,
    required this.accent,
    required this.onAccent,
    required this.primaryText,
    required this.mutedText,
    required this.subtleText,
    required this.icon,
    required this.hint,
    required this.searchFill,
    required this.success,
    required this.tabContainer,
    required this.emptyIcon,
    required this.selectionFill,
    required this.selectionBorder,
  });

  final Color background;
  final Color surface;
  final Color outline;
  final Color accent;
  final Color onAccent;
  final Color primaryText;
  final Color mutedText;
  final Color subtleText;
  final Color icon;
  final Color hint;
  final Color searchFill;
  final Color success;
  final Color tabContainer;
  final Color emptyIcon;
  final Color selectionFill;
  final Color selectionBorder;

  factory ControlTiemposPalette.of(ThemeData theme) {
    final scheme = theme.colorScheme;
    final bool isDark = scheme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>();

    final Color background = theme.scaffoldBackgroundColor;
    final Color surface = theme.cardColor;
    final Color outline = scheme.outline.withOpacity(isDark ? 0.35 : 0.5);
    final Color accent = scheme.secondary;
    final Color onAccent = scheme.onSecondary;
    final Color primaryText = scheme.onSurface;
    final Color mutedText = scheme.onSurface.withOpacity(isDark ? 0.78 : 0.7);
    final Color subtleText = scheme.onSurfaceVariant;
    final Color icon = scheme.onSurface;
    final Color hint = scheme.onSurface.withOpacity(isDark ? 0.5 : 0.45);
    final Color searchFill = theme.inputDecorationTheme.fillColor ??
        scheme.surfaceVariant.withOpacity(isDark ? 0.35 : 0.85);
    final Color success = appColors?.success ?? const Color(0xFF4CAF50);
    final Color tabContainer =
        scheme.surfaceVariant.withOpacity(isDark ? 0.45 : 0.9);
    final Color emptyIcon = scheme.onSurface.withOpacity(0.25);
    final Color selectionFill = accent.withOpacity(isDark ? 0.18 : 0.2);
    final Color selectionBorder = accent.withOpacity(isDark ? 0.8 : 0.6);

    return ControlTiemposPalette(
      background: background,
      surface: surface,
      outline: outline,
      accent: accent,
      onAccent: onAccent,
      primaryText: primaryText,
      mutedText: mutedText,
      subtleText: subtleText,
      icon: icon,
      hint: hint,
      searchFill: searchFill,
      success: success,
      tabContainer: tabContainer,
      emptyIcon: emptyIcon,
      selectionFill: selectionFill,
      selectionBorder: selectionBorder,
    );
  }
}
