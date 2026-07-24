import 'package:flutter/material.dart';

import '../ui/theme/pola_colors.dart';

/// Animasi loading AI — tiga titik berdenyut.
class AiLoadingIndicator extends StatefulWidget {
  const AiLoadingIndicator({super.key, this.size = 10});

  final double size;

  @override
  State<AiLoadingIndicator> createState() => _AiLoadingIndicatorState();
}

class _AiLoadingIndicatorState extends State<AiLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_c.value + i * 0.22) % 1.0;
          final scale = 0.5 + (t < 0.5 ? t : 1 - t);
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: const BoxDecoration(
                  color: PolaColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
