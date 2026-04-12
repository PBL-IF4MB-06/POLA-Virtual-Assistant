import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'login_page.dart';

class SettingsV4Page extends StatelessWidget {
  const SettingsV4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final theme = AppStateScope.of(context).theme;
    final settings = AppStateScope.of(context).settings;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, theme, settings]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primary.withValues(alpha: 0.18),
                  child: const Icon(Icons.person),
                ),
                title: Text(auth.isLoggedIn ? auth.displayName : 'Guest'),
                subtitle: Text(
                  auth.isLoggedIn ? auth.email : 'Login untuk sinkron preferensi',
                ),
                trailing: auth.isLoggedIn
                    ? TextButton(
                        onPressed: auth.logout,
                        child: const Text('Logout'),
                      )
                    : FilledButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        },
                        child: const Text('Login'),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            _SectionTitle('Tampilan'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: const Text('Mode'),
                    subtitle: Text(_modeLabel(theme.mode)),
                    onTap: () => _pickMode(context, theme),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Aksen (v4)'),
                    subtitle: const Text('Ungu premium'),
                    onTap: () => theme.setSeedColor(const Color(0xFF7C3AED)),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionTitle('Web search'),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.public),
                    title: const Text('Aktifkan web search'),
                    value: settings.webSearchEnabled,
                    onChanged: settings.setWebSearchEnabled,
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: TextField(
                      controller:
                          TextEditingController(text: settings.googleCseApiKey),
                      onChanged: settings.setGoogleCseApiKey,
                      decoration: const InputDecoration(
                        labelText: 'Google API Key (opsional)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: TextField(
                      controller:
                          TextEditingController(text: settings.googleCseCx),
                      onChanged: settings.setGoogleCseCx,
                      decoration: const InputDecoration(
                        labelText: 'Search Engine ID / cx (opsional)',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset data (v4)'),
                subtitle: const Text('Chat dan preferensi akan fresh karena key v4'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sudah reset total: sekarang pakai key v4.'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickMode(BuildContext context, dynamic theme) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: theme.mode,
          onChanged: (v) => Navigator.of(context).pop(v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(title: Text('Mode tampilan')),
              RadioListTile(value: ThemeMode.system, title: Text('System')),
              RadioListTile(value: ThemeMode.light, title: Text('Light')),
              RadioListTile(value: ThemeMode.dark, title: Text('Dark')),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null) await theme.setMode(picked);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(color: cs.onSurfaceVariant),
    );
  }
}

String _modeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
    };

