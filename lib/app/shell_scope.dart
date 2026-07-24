import 'package:flutter/material.dart';

/// Navigasi antar tab utama (Home, Chat, Informasi, Pengumuman, Profil).
class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.goToTab,
    required super.child,
  });

  final void Function(ShellTab tab, {String? chatPrompt}) goToTab;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();
    assert(scope != null, 'No ShellScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => goToTab != oldWidget.goToTab;
}

enum ShellTab { home, chat, campus, profile }
