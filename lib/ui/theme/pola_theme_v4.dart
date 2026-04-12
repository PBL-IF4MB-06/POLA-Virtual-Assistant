import 'package:flutter/material.dart';

class PolaThemeV4 {
  static ThemeData light(Color seed) {
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xFFF7F7FB),
    );
    return _base(cs, Brightness.light);
  }

  static ThemeData dark(Color seed) {
    final cs = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF0E0F14),
    );
    return _base(cs, Brightness.dark);
  }

  static ThemeData _base(ColorScheme cs, Brightness b) {
    final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: cs);
    final isDark = b == Brightness.dark;

    return base.copyWith(
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0B0C10) : const Color(0xFFF7F7FB),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.28),
        bodySmall: base.textTheme.bodySmall?.copyWith(height: 1.28),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor:
            isDark ? const Color(0xFF0B0C10) : Colors.white.withValues(alpha: 0.98),
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.96),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.55)),
        ),
      ),
    );
  }
}

