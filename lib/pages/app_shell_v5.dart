import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'chat_page.dart';

class AppShellV5 extends StatelessWidget {
  const AppShellV5({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return Scaffold(
          drawer: const _HistoryDrawer(),
          appBar: AppBar(
            title: const Text('POLA Copilot'),
            actions: [
              IconButton(
                tooltip: 'New chat',
                onPressed: chat.startNewConversation,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 6),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Theme.of(context).dividerTheme.color,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ChatPage(
                showFeatureHeader: true,
              ),
            ),
          ),
          floatingActionButton: chat.conversations.length <= 1
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  icon: const Icon(Icons.history),
                  label: const Text('History'),
                ),
        );
      },
    );
  }
}

class _HistoryDrawer extends StatelessWidget {
  const _HistoryDrawer();

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: chat,
          builder: (context, _) {
            final activeId = chat.activeConversation.id;
            final convos = chat.conversations;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'History',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'New chat',
                        onPressed: () {
                          chat.startNewConversation();
                          Navigator.of(context).maybePop();
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerTheme.color),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    itemBuilder: (context, i) {
                      final c = convos[i];
                      final selected = c.id == activeId;
                      return Material(
                        color: selected
                            ? cs.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          dense: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Icon(
                            selected ? Icons.chat_bubble : Icons.chat_bubble_outline,
                            size: 18,
                          ),
                          title: Text(
                            c.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            c.lastMessage?.text.trim().isNotEmpty == true
                                ? c.lastMessage!.text.trim()
                                : 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            chat.setActiveConversation(c.id);
                            Navigator.of(context).maybePop();
                          },
                          trailing: IconButton(
                            tooltip: 'Delete',
                            onPressed: convos.length <= 1
                                ? null
                                : () => chat.deleteConversation(c.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemCount: convos.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: chat.clearAllConversations,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Clear all'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

