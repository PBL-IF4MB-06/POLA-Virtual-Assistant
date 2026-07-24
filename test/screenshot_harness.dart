import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pola_app/app/app_state_scope.dart';
import 'package:pola_app/app/shell_scope.dart';
import 'package:pola_app/state/auth_state.dart';
import 'package:pola_app/state/bookmark_state.dart';
import 'package:pola_app/state/chat_state.dart';
import 'package:pola_app/state/notification_state.dart';
import 'package:pola_app/state/settings_state.dart';
import 'package:pola_app/state/theme_state.dart';
import 'package:pola_app/ui/theme/pola_theme_v6.dart';

import 'flutter_test_config.dart' show screenshotTheme;

/// Ukuran logis layar mobile (iPhone 14 class).
const kScreenshotLogicalSize = Size(390, 844);

/// 3x agar teks & ikon tajam saat di-zoom / dicetak laporan.
const kScreenshotDevicePixelRatio = 3.0;

class ScreenshotHarness {
  final auth = AuthState();
  final settings = SettingsState();
  final theme = ThemeState();
  final bookmarks = BookmarkState();
  final notifications = NotificationState();
  late final ChatState chat;

  ScreenshotHarness() {
    chat = ChatState(settings: settings);
  }

  static Future<ScreenshotHarness> create({
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final harness = ScreenshotHarness();
    await harness.auth.load();
    await harness.chat.loadFromStorage();
    await harness.settings.load();
    await harness.theme.load();
    await harness.bookmarks.load();
    await harness.notifications.load();
    return harness;
  }

  Widget wrap(
    Widget child, {
    bool withShell = false,
    void Function(ShellTab tab, {String? chatPrompt})? goToTab,
  }) {
    return AppStateScope(
      auth: auth,
      chat: chat,
      settings: settings,
      theme: theme,
      bookmarks: bookmarks,
      notifications: notifications,
      child: AnimatedBuilder(
        animation: theme,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: screenshotTheme(PolaThemeV6.light(theme.seedColor)),
            darkTheme: screenshotTheme(PolaThemeV6.dark(theme.seedColor)),
            themeMode: theme.mode,
            home: withShell
                ? ShellScope(
                    goToTab: goToTab ?? (_, {String? chatPrompt}) {},
                    child: child,
                  )
                : child,
          );
        },
      ),
    );
  }

  void configureView(WidgetTester tester) {
    tester.view.devicePixelRatio = kScreenshotDevicePixelRatio;
    tester.view.physicalSize = Size(
      kScreenshotLogicalSize.width * kScreenshotDevicePixelRatio,
      kScreenshotLogicalSize.height * kScreenshotDevicePixelRatio,
    );
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Future<void> pumpScreenshot(
    WidgetTester tester,
    Widget child, {
    bool withShell = false,
    Duration settleTimeout = const Duration(seconds: 2),
  }) async {
    configureView(tester);
    await tester.pumpWidget(wrap(child, withShell: withShell));
    await tester.pumpAndSettle(settleTimeout);
  }

  Future<void> saveGolden(WidgetTester tester, String name) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../screenshots/$name'),
    );
  }
}
