import 'package:flutter/material.dart';

import 'pola_colors.dart';

class PolaThemeV6 {
  static const Color seed = PolaColors.primary;

  static ThemeData light([Color? seedColor]) {
    final accent = seedColor ?? seed;
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      primary: PolaColors.primary,
      secondary: PolaColors.secondary,
      surface: Colors.white,
    );
    return _base(cs, Brightness.light);
  }

  static ThemeData dark([Color? seedColor]) {
    final accent = seedColor ?? seed;
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      primary: PolaColors.secondary,
      secondary: PolaColors.primary,
      surface: PolaColors.darkSurface,
    );
    return _base(cs, Brightness.dark);
  }

  static ThemeData _base(ColorScheme cs, Brightness b) {
    final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: cs);
    final isDark = b == Brightness.dark;
    final bg = isDark ? PolaColors.darkBackground : PolaColors.background;

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? PolaColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: isDark ? PolaColors.darkSurface : Colors.white,
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.25 : 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PolaColors.primary,
          foregroundColor: PolaColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PolaColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
