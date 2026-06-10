import 'package:flutter/material.dart';

import 'app/app_state_scope.dart';
import 'config/env_config.dart';
import 'pages/app_shell_v7.dart';
import 'services/supabase/supabase_service.dart';
import 'state/auth_state.dart';
import 'state/chat_state.dart';
import 'state/settings_state.dart';
import 'state/theme_state.dart';
import 'ui/theme/pola_theme_v6.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  await SupabaseService.initialize();
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
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _auth.load();
    await _chat.loadFromStorage();
    await _settings.load();
    await _theme.load();
    if (mounted) setState(() => _ready = true);
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
            home: _ready
                ? const AppShellV7()
                : const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
          );
        },
      ),
    );
  }
}
