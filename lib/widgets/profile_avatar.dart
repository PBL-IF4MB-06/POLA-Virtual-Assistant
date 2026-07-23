import 'dart:convert';

import 'package:flutter/material.dart';

import '../ui/theme/pola_colors.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarBase64 = '',
    this.radius = 44,
    this.fontSize,
  });

  final String name;
  final String avatarBase64;
  final double radius;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';
    final b64 = avatarBase64.trim();

    if (b64.isNotEmpty) {
      try {
        final bytes = base64Decode(b64);
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          backgroundImage: MemoryImage(bytes),
        );
      } catch (_) {
        // fallback ke inisial
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: fontSize ?? radius * 0.82,
          fontWeight: FontWeight.w900,
          color: PolaColors.primary,
        ),
      ),
    );
  }
}
