import 'dart:async';

import 'package:flutter/material.dart';
import '../app/app_state_scope.dart';
import 'admin/admin_dashboard_page.dart';
import 'login_page.dart';
import 'profile/edit_profile_dialog.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.showAppBar = true});

  /// When false (e.g. embedded in a sheet that already has a title/close), no [AppBar] is shown.
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final theme = AppStateScope.of(context).theme;
    final settings = AppStateScope.of(context).settings;

    final body = AnimatedBuilder(
      animation: Listenable.merge([auth, settings, theme]),
      builder: (context, _) {
        final isDark = theme.mode == ThemeMode.dark;
        final effectiveName = settings.profileName.isNotEmpty
            ? settings.profileName
            : auth.displayName;
        final handleBase = settings.username.isNotEmpty
            ? settings.username
            : (auth.email.split('@').first);
        final handle = '@$handleBase';

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _GroupHeader('Tampilan'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _SwitchRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'Mode Gelap',
                  value: isDark,
                  onChanged: (v) =>
                      theme.setMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
                _NavRow(
                  icon: Icons.palette_outlined,
                  title: 'Warna aksen',
                  trailing: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: theme.seedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  onTap: () => _pickSeedColor(context, theme),
                ),
                _SwitchRow(
                  icon: Icons.vibration_outlined,
                  title: 'Umpan balik haptik',
                  value: settings.hapticFeedback,
                  onChanged: settings.setHapticFeedback,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GroupHeader('Chatbot AI'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _SwitchRow(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Saran pertanyaan lanjutan',
                  subtitle: 'Chip rekomendasi setelah jawaban bot',
                  value: settings.followUpSuggestions,
                  onChanged: settings.setFollowUpSuggestions,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _GroupHeader('Akun'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _NavRow(
                  icon: Icons.person_outline,
                  title: auth.isLoggedIn ? auth.displayName : 'Tamu',
                  trailing: Text(
                    auth.isLoggedIn ? 'Keluar' : 'Masuk',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () async {
                    if (auth.isLoggedIn) {
                      await auth.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anda telah keluar.')),
                        );
                      }
                    } else {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    }
                  },
                ),
                if (!auth.isLoggedIn)
                  _NavRow(
                    icon: Icons.app_registration_outlined,
                    title: 'Buat akun baru',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              const LoginPage(initialLoginMode: false),
                        ),
                      );
                    },
                  ),
              ],
            ),
            if (auth.isAdmin) ...[
              const SizedBox(height: 16),
              _GroupHeader('Admin'),
              const SizedBox(height: 8),
              _SurfaceCard(
                children: [
                  _NavRow(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Panel Admin',
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _GroupHeader('Profil'),
            const SizedBox(height: 8),
            _SurfaceCard(
              children: [
                _NavRow(
                  icon: Icons.badge_outlined,
                  title: 'Edit Profil',
                  trailing: _ProfilePill(name: effectiveName, handle: handle),
                  onTap: () => showEditProfileDialog(context),
                ),
                _NavRow(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'POLA v1.0.0 — Demo PBL',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!showAppBar) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: body,
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.name, required this.handle});
  final String name;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          handle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface.withValues(alpha: 0.82),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(children: _withDividers(children)),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

List<Widget> _withDividers(List<Widget> children) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    out.add(children[i]);
    if (i != children.length - 1) {
      out.add(const Divider(height: 1));
    }
  }
  return out;
}

Future<void> _pickSeedColor(BuildContext context, dynamic theme) async {
  const colors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFF059669),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
    Color(0xFFEA580C),
  ];

  final picked = await showModalBottomSheet<Color>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih warna aksen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in colors)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(c),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.seedColor == c
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: c.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  if (picked != null) {
    await theme.setSeedColor(picked);
  }
}

Future<void> _showAbout(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tentang POLA',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              'Implementasi Chatbot AI pada Aplikasi POLA Berbasis Mobile — '
              'asisten virtual untuk Politeknik Negeri Batam. Chatbot membahas '
              'beasiswa, akademik, jurusan, laboratorium, magang, dan layanan kampus. '
              'Pertanyaan di luar konteks Polibatam tidak dilayani.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Versi 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
