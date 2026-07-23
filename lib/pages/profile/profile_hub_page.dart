import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/profile_avatar.dart';
import '../admin/admin_dashboard_page.dart';
import '../login_page.dart';
import '../settings_page.dart';
import 'bookmarks_page.dart';
import 'chat_history_page.dart';
import 'edit_profile_dialog.dart';

/// Profil ringkas untuk demo — menu penting saja.
class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final settings = AppStateScope.of(context).settings;
    final bookmarks = AppStateScope.of(context).bookmarks;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, settings, bookmarks]),
      builder: (context, _) {
        final name = settings.profileName.isNotEmpty
            ? settings.profileName
            : auth.displayName;
        final handle = settings.username.isNotEmpty
            ? '@${settings.username}'
            : (auth.isLoggedIn ? auth.email : 'Tamu');
        final prodi = settings.programStudi.isNotEmpty
            ? settings.programStudi
            : 'Polibatam';

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 28),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [PolaColors.primary, PolaColors.secondary],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        name: name,
                        avatarBase64: settings.avatarBase64,
                        radius: 48,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      Text(
                        handle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                      ),
                      Text(
                        prodi,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => showEditProfileDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit Profil'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _MenuCard(
                      icon: auth.isLoggedIn
                          ? Icons.logout_rounded
                          : Icons.login_rounded,
                      title: auth.isLoggedIn ? 'Keluar Akun' : 'Login / Daftar',
                      subtitle: auth.isLoggedIn
                          ? auth.email
                          : 'Masuk, daftar, atau lanjut dengan Google',
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
                    _MenuCard(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Chat',
                      onTap: () => _push(context, const ChatHistoryPage()),
                    ),
                    _MenuCard(
                      icon: Icons.bookmark_rounded,
                      title: 'Bookmark Jawaban',
                      subtitle: '${bookmarks.items.length} tersimpan',
                      onTap: () => _push(context, const BookmarksPage()),
                    ),
                    _MenuCard(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: () => _push(context, const SettingsPage()),
                    ),
                    // Panel Admin hanya setelah login sebagai admin lewat Login/Daftar.
                    if (auth.isAdmin)
                      _MenuCard(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Panel Admin',
                        subtitle: 'Kelola FAQ & monitoring sistem',
                        onTap: () =>
                            _push(context, const AdminDashboardPage()),
                      ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () =>
                          ShellScope.of(context).goToTab(ShellTab.chat),
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('Buka Chatbot AI'),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: PolaColors.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: PolaColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
