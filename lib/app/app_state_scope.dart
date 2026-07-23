import 'package:flutter/material.dart';

import '../state/auth_state.dart';
import '../state/bookmark_state.dart';
import '../state/chat_state.dart';
import '../state/notification_state.dart';
import '../state/settings_state.dart';
import '../state/theme_state.dart';

class AppStateScope extends InheritedWidget {
  const AppStateScope({
    super.key,
    required this.auth,
    required this.chat,
    required this.settings,
    required this.theme,
    required this.bookmarks,
    required this.notifications,
    required super.child,
  });

  final AuthState auth;
  final ChatState chat;
  final SettingsState settings;
  final ThemeState theme;
  final BookmarkState bookmarks;
  final NotificationState notifications;

  static AppStateScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppStateScope oldWidget) =>
      auth != oldWidget.auth ||
      chat != oldWidget.chat ||
      settings != oldWidget.settings ||
      theme != oldWidget.theme ||
      bookmarks != oldWidget.bookmarks ||
      notifications != oldWidget.notifications;
}

