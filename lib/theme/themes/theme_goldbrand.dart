import 'package:flutter/material.dart';
import '../tokens/color_schemes.dart';
import '../tokens/typography.dart';
import '../extensions/app_colors.dart';

final goldBrandTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme.copyWith(primary: const Color(0xFFC58E00)),
  textTheme: buildTextTheme(lightColorScheme),
  extensions: const [
    AppColors(success: Color(0xFF10B981), warning: Color(0xFFF59E0B)),
  ],
);
