import 'package:flutter/material.dart';

class PolaThemeV6 {
  /// Aksen utama aplikasi (nuansa biru langit).
  static const Color seed = Color(0xFF9CD5FF);

  static ThemeData light([Color? seedColor]) {
    final accent = seedColor ?? seed;
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFFFF),
    ).copyWith(
      primary: accent,
      onPrimary: const Color(0xFF0B2233),
    );
    return _base(cs, Brightness.light);
  }

  static ThemeData dark([Color? seedColor]) {
    final accent = seedColor ?? seed;
    final cs = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: const Color(0xFF101418),
    ).copyWith(
      primary: accent,
      onPrimary: const Color(0xFF0B2233),
    );
    return _base(cs, Brightness.dark);
  }

  static ThemeData _base(ColorScheme cs, Brightness b) {
    final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: cs);
    final isDark = b == Brightness.dark;

    final bg = isDark ? const Color(0xFF0A1118) : const Color(0xFFEEF6FB);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: -0.3,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor:
            isDark ? const Color(0xFF0A1118) : Colors.white.withValues(alpha: 0.98),
        indicatorColor: cs.primary.withValues(alpha: isDark ? 0.22 : 0.12),
        labelTextStyle: WidgetStatePropertyAll(
          base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.50)),
        ),
      ),
    );
  }
}

