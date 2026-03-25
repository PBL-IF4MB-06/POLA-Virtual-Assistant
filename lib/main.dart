import 'package:flutter/material.dart';

import 'app/app_state_scope.dart';
import 'pages/home_shell.dart';
import 'state/auth_state.dart';
import 'state/chat_state.dart';
import 'state/settings_state.dart';
import 'state/theme_state.dart';

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
  final ChatState _chat = ChatState();
  final SettingsState _settings = SettingsState();
  final ThemeState _theme = ThemeState();

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
          final baseLight = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _theme.seedColor,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF3F5F9),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          );

          final baseDark = ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _theme.seedColor,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          );

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: baseLight,
            darkTheme: baseDark,
            themeMode: _theme.mode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
