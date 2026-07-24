import 'package:flutter/material.dart';

import '../ui/theme/pola_colors.dart';

class ModernGradientBackground extends StatelessWidget {
  const ModernGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  PolaColors.darkBackground,
                  const Color(0xFF1E3A5F),
                  PolaColors.darkBackground,
                ]
              : [
                  const Color(0xFFEFF6FF),
                  PolaColors.background,
                  const Color(0xFFDBEAFE),
                ],
        ),
      ),
      child: child,
    );
  }
}
