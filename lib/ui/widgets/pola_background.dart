import 'package:flutter/material.dart';

class PolaBackground extends StatelessWidget {
  const PolaBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseA = isDark ? const Color(0xFF08101E) : const Color(0xFFEAF2FF);
    final baseB = isDark ? const Color(0xFF040814) : const Color(0xFFF7FBFF);

    return Stack(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                baseA,
                cs.primary.withValues(alpha: isDark ? 0.10 : 0.08),
                baseB,
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        // soft "cloud" blobs (mockup-like)
        Positioned(
          left: -120,
          top: -80,
          child: _Blob(
            size: 320,
            color: cs.primary.withValues(alpha: isDark ? 0.10 : 0.22),
          ),
        ),
        Positioned(
          right: -140,
          top: 60,
          child: _Blob(
            size: 360,
            color: cs.tertiary.withValues(alpha: isDark ? 0.08 : 0.18),
          ),
        ),
        Positioned(
          left: -160,
          bottom: -120,
          child: _Blob(
            size: 420,
            color: cs.secondary.withValues(alpha: isDark ? 0.06 : 0.16),
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: color.a * 0.75),
              blurRadius: 80,
              spreadRadius: 30,
            ),
          ],
        ),
      ),
    );
  }
}

