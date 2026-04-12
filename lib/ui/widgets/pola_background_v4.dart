import 'package:flutter/material.dart';

class PolaBackgroundV4 extends StatelessWidget {
  const PolaBackgroundV4({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.7, -0.8),
          radius: 1.35,
          colors: [
            cs.primary.withValues(alpha: isDark ? 0.22 : 0.14),
            isDark ? const Color(0xFF0B0C10) : const Color(0xFFF7F7FB),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: child,
    );
  }
}

