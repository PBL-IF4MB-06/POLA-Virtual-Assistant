import 'package:flutter/material.dart';

import 'app/app_state_scope.dart';
import 'pages/app_shell_v7.dart';
import 'state/auth_state.dart';
import 'state/chat_state.dart';
import 'state/settings_state.dart';
import 'state/theme_state.dart';
import 'ui/theme/pola_theme_v6.dart';

void main() {
  runApp(const POLAApp());
}

class POLAApp extends StatefulWidget {
  const POLAApp({super.key});

  @override
  State<POLAApp> createState() => _POLAAppState();
}

class _POLAAppState extends State<POLAApp> {
  final AuthState _auth = AuthState();
  final SettingsState _settings = SettingsState();
  final ThemeState _theme = ThemeState();
  late final ChatState _chat = ChatState(settings: _settings);

  @override
  void initState() {
    super.initState();
    _auth.load();
    _chat.loadFromStorage();
    _settings.load();
    _theme.load();
  }

  @override
  void dispose() {
    _auth.dispose();
    _chat.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      auth: _auth,
      chat: _chat,
      settings: _settings,
      theme: _theme,
      child: AnimatedBuilder(
        animation: _theme,
        builder: (context, _) {
          final light = PolaThemeV6.light(_theme.seedColor);
          final dark = PolaThemeV6.dark(_theme.seedColor);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: light,
            darkTheme: dark,
            themeMode: _theme.mode,
            home: const AppShellV7(),
          );
        },
      ),
    );
  }
}
