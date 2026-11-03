import 'package:flutter/material.dart';

extension AppColorsExtension on BuildContext {
  AppColors get colors => AppColors(this);
}

class AppColors {
  final BuildContext context;
  AppColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get primary => const Color(0xFF15171F);
  Color get secondary => const Color(0xFF5F6671);
  Color get fog => const Color(0xFF9CA3AF);
  Color get mist => const Color(0xFFCDD7E5);
  Color get canvas => const Color(0xFFF0F2F4);

  // Palette-only semantic aliases — no green, blue, orange
  Color get accent => secondary;   // Slate: strong secondary highlight
  Color get subtle => fog;         // Fog: de-emphasised/neutral
  Color get success => primary;    // Midnight: completed/confirmed
  Color get red => isDark ? const Color(0xFFEF5350) : const Color(0xFFEF4444);
  Color get error => red;

  Color get black => isDark ? Colors.white : const Color(0xFF15171F);
  Color get white => isDark ? const Color(0xFF15171F) : Colors.white;
  Color get grey => isDark ? const Color(0xFFB0B0B0) : const Color(0xFF5F6671);
  Color get lightGrey => isDark ? const Color(0xFF3D3D3D) : const Color(0xFF9CA3AF);
  Color get textLight => lightGrey;
  Color get text => black;
  Color get border => mist;
  Color get background => isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F4);
  Color get backgroundLight => canvas;
  Color get surface => isDark ? const Color(0xFF1E1E1E) : Colors.white;

  Color get shimmerBase => grey.withValues(alpha: 0.3);
  Color get shimmerHighlight => grey.withValues(alpha: 0.1);
}
