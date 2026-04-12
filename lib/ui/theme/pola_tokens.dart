import 'package:flutter/material.dart';

class PolaTokens {
  static const double r12 = 12;
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;

  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(18, 14, 18, 18);

  static List<BoxShadow> softShadow(Color base) => [
        BoxShadow(
          color: base.withValues(alpha: 0.10),
          blurRadius: 22,
          offset: const Offset(0, 12),
        ),
      ];
}

