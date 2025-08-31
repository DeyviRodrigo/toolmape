import 'package:flutter/material.dart';

/// ThemeExtension: ToolmapeTheme - colores de marca.
@immutable
class ToolmapeTheme extends ThemeExtension<ToolmapeTheme> {
  final Color brandGold;

  const ToolmapeTheme({required this.brandGold});

  @override
  ToolmapeTheme copyWith({Color? brandGold}) {
    return ToolmapeTheme(brandGold: brandGold ?? this.brandGold);
  }

  @override
  ToolmapeTheme lerp(ThemeExtension<ToolmapeTheme>? other, double t) {
    if (other is! ToolmapeTheme) return this;
    return ToolmapeTheme(brandGold: Color.lerp(brandGold, other.brandGold, t)!);
  }
}
