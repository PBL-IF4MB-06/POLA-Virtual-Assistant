import 'package:flutter/material.dart';

/// Navigasi antar tab utama (Beranda, Chatbot, Info Kampus, Profil).
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

  /// Pindah ke Chatbot dan tutup halaman yang menumpuk (detail kampus, dll).
  void openChat(BuildContext context, {String? chatPrompt}) {
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    }
    goToTab(ShellTab.chat, chatPrompt: chatPrompt);
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => goToTab != oldWidget.goToTab;
}

enum ShellTab { home, chat, campus, profile }
