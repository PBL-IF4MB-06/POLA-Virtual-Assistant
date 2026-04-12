import 'package:flutter/material.dart';

import 'pola_tokens.dart';

class PolaTheme {
  static ThemeData light(Color seed) {
    // Konsep baru (v3): clean bright premium (off-white + blue).
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );
    return _base(cs, Brightness.light);
  }

  static ThemeData dark(Color seed) {
    // Konsep baru (v3): dark premium (navy) dengan accent blue.
    final cs =
        ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB), brightness: Brightness.dark);
    return _base(cs, Brightness.dark);
  }

  static ThemeData _base(ColorScheme cs, Brightness b) {
    final isDark = b == Brightness.dark;
    final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: cs);

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? const Color(0xFF0B1020) : const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: _premiumTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.86),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PolaTokens.r24),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PolaTokens.r16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PolaTokens.r16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PolaTokens.r16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PolaTokens.r16),
          borderSide: BorderSide(
            color: cs.primary.withValues(alpha: 0.55),
          ),
        ),
        isDense: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? const Color(0xFF0B1020).withValues(alpha: 0.86) : Colors.white,
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.18 : 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? cs.onSurface : null,
          ),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: isDark ? cs.onSurfaceVariant : null),
        ),
      ),
    );
  }
}

TextTheme _premiumTextTheme(TextTheme base) {
  return base.copyWith(
    titleLarge:
        base.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3),
    titleMedium:
        base.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2),
    titleSmall:
        base.titleSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.1),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.25),
    bodySmall: base.bodySmall?.copyWith(height: 1.25),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );
}

