import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../ui/widgets/pola_background.dart';
import '../widgets/pola_logo.dart';
import 'chat_page.dart';
import 'chat_search_delegate.dart';
import 'settings_page.dart';

/// UI v7 mengikuti mockup: topbar POLA + halaman:
/// - Home (chat)
/// - Riwayat (list chat + quick prompts) -> sementara pakai Home + drawer history internal chat state
/// - Pengaturan
class AppShellV7 extends StatefulWidget {
  const AppShellV7({super.key});

  @override
  State<AppShellV7> createState() => _AppShellV7State();
}

class _AppShellV7State extends State<AppShellV7> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;

    final pages = const [
      _HomeChatV7(),
      _HistoryV7(),
      _SettingsV7Proxy(),
    ];

    return PolaBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              _TopBarV7(
                onSearch: () async {
                  final messages = chat.activeConversation.messages;
                  await showSearch(
                    context: context,
                    delegate: ChatSearchDelegate(messages: messages),
                  );
                },
              ),
              Expanded(
                child: AnimatedBuilder(
                  animation: chat,
                  builder: (context, _) {
                    return IndexedStack(index: _index, children: pages);
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarV7 extends StatelessWidget {
  const _TopBarV7({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          const PolaLogo(size: 30),
          const SizedBox(width: 10),
          Text(
            'POLA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Cari',
            onPressed: onSearch,
            icon: Icon(Icons.search, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _HomeChatV7 extends StatelessWidget {
  const _HomeChatV7();

  @override
  Widget build(BuildContext context) {
    return const ChatPage(showFeatureHeader: true);
  }
}

class _HistoryV7 extends StatefulWidget {
  const _HistoryV7();

  @override
  State<_HistoryV7> createState() => _HistoryV7State();
}

class _HistoryV7State extends State<_HistoryV7> {
  final TextEditingController _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        final convos = chat.conversations;
        final query = _q.text.trim().toLowerCase();
        final filtered = query.isEmpty
            ? convos
            : convos.where((c) {
                final t = c.title.toLowerCase();
                final last = (c.lastMessage?.text ?? '').toLowerCase();
                return t.contains(query) || last.contains(query);
              }).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cs.surface.withValues(alpha: 0.82),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Riwayat Chat',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: chat.startNewConversation,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                  IconButton(
                    tooltip: 'Hapus semua',
                    onPressed: convos.isEmpty
                        ? null
                        : () async {
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
                            if (ok == true) chat.clearAllConversations();
                          },
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _q,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari riwayat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        onPressed: () {
                          _q.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 10),
                child: Text(
                  convos.isEmpty
                      ? 'Belum ada riwayat chat. Mulai chat dulu ya.'
                      : 'Tidak ada yang cocok dengan pencarian.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              )
            else
              for (final c in filtered) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surface.withValues(alpha: 0.82),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Dismissible(
                    key: ValueKey('convo_${c.id}'),
                    direction: convos.length <= 1
                        ? DismissDirection.none
                        : DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: cs.error.withValues(alpha: 0.12),
                      child: Icon(Icons.delete_outline, color: cs.error),
                    ),
                    onDismissed: (_) => chat.deleteConversation(c.id),
                    child: ListTile(
                      leading: const PolaLogo(size: 28),
                      title: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      subtitle: Text(
                        c.lastMessage?.text.trim().isNotEmpty == true
                            ? c.lastMessage!.text.trim()
                            : '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => chat.setActiveConversation(c.id),
                    ),
                  ),
                ),
              ],
          ],
        );
      },
    );
  }
}

class _SettingsV7Proxy extends StatelessWidget {
  const _SettingsV7Proxy();

  @override
  Widget build(BuildContext context) {
    // Reuse existing settings logic, UI will be redesigned next.
    return const SettingsPage();
  }
}

