import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../ui/widgets/pola_background.dart';
import '../widgets/auth_welcome_dialog.dart';
import '../widgets/pola_logo.dart';
import 'chat_page.dart';
import 'settings_page.dart';

/// Shell utama: chat penuh + drawer kiri (ala ChatGPT) untuk riwayat & pengaturan.
class AppShellV7 extends StatefulWidget {
  const AppShellV7({super.key});

  @override
  State<AppShellV7> createState() => _AppShellV7State();
}

class _AppShellV7State extends State<AppShellV7> {
  bool _authPromptChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowAuthWelcome());
  }

  Future<void> _maybeShowAuthWelcome() async {
    if (_authPromptChecked || !mounted) return;
    _authPromptChecked = true;

    final auth = AppStateScope.of(context).auth;
    if (auth.isLoggedIn) return;

    await showAuthWelcomeDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final auth = AppStateScope.of(context).auth;

    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        return PolaBackground(
          child: AnimatedBuilder(
            animation: chat,
            builder: (context, _) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                drawer: const _PolaDrawer(),
                body: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TopBarV7(),
                      const Expanded(
                        child: ChatPage(showFeatureHeader: true),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TopBarV7 extends StatelessWidget {
  const _TopBarV7();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
          const PolaLogo(size: 44),
        ],
      ),
    );
  }
}

class _PolaDrawer extends StatelessWidget {
  const _PolaDrawer();

  static void _closeDrawer(BuildContext context) {
    final nav = Navigator.maybeOf(context);
    if (nav?.canPop() == true) nav!.pop();
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: chat,
          builder: (context, _) {
            final convos = chat.conversations;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                  child: Row(
                    children: [
                      const PolaLogo(size: 52),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => _closeDrawer(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () {
                        chat.startNewConversation();
                        _closeDrawer(context);
                      },
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Chat baru'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Riwayat',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: convos.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Belum ada percakapan.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          itemCount: convos.length,
                          itemBuilder: (context, i) {
                            final c = convos[i];
                            final active = chat.activeConversation.id == c.id;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Material(
                                color: active
                                    ? cs.primary.withValues(alpha: isDark ? 0.18 : 0.14)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                child: ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    c.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                  ),
                                  subtitle: Text(
                                    c.lastMessage?.text.trim().isNotEmpty == true
                                        ? c.lastMessage!.text.trim()
                                        : '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                  ),
                                  trailing: convos.length <= 1
                                      ? null
                                      : PopupMenuButton<String>(
                                          icon: Icon(
                                            Icons.more_horiz_rounded,
                                            color: cs.onSurfaceVariant,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onSelected: (v) {
                                            if (v == 'delete') {
                                              chat.deleteConversation(c.id);
                                            }
                                          },
                                          itemBuilder: (context) => const [
                                            PopupMenuItem<String>(
                                              value: 'delete',
                                              child: Text('Hapus chat'),
                                            ),
                                          ],
                                        ),
                                  onTap: () {
                                    chat.setActiveConversation(c.id);
                                    _closeDrawer(context);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                if (convos.isNotEmpty)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.delete_sweep_outlined, color: cs.error),
                    title: Text(
                      'Hapus semua riwayat',
                      style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                    ),
                    onTap: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus semua riwayat?'),
                          content: const Text(
                            'Semua percakapan akan dihapus dari perangkat ini.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Batal'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true && context.mounted) {
                        chat.clearAllConversations();
                      }
                    },
                  ),
                ListTile(
                  dense: true,
                  leading: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
                  title: const Text('Pengaturan'),
                  onTap: () async {
                    final nav = Navigator.of(context);
                    nav.pop();
                    await nav.push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.paddingOf(context).bottom),
              ],
            );
          },
        ),
      ),
    );
  }
}
