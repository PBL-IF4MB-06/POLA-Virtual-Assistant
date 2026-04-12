import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'chat_page.dart';
import 'settings_page.dart';
import '../widgets/chat_feature_header.dart';
import '../widgets/chat_launcher_fab.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  DateTime _lastChatSeenAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastSeenMessageId;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final convo = chat.activeConversation;
    final lastMessage = convo.lastMessage;
    final hasUnread = lastMessage != null &&
        lastMessage.createdAt.isAfter(_lastChatSeenAt) &&
        lastMessage.id != _lastSeenMessageId;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  convo.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'POLA - Polibatam Assistant',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Buka chat',
                onPressed: () => _openChatFullScreen(context),
                icon: const Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
          drawer: _ChatsDrawer(
            activeId: chat.activeConversation.id,
            onSelect: (id) {
              chat.setActiveConversation(id);
              Navigator.of(context).pop();
            },
            onNewChat: () {
              chat.startNewConversation();
              Navigator.of(context).pop();
            },
            onGoSettings: () {
              Navigator.of(context).pop();
              _openSettingsSheet(context);
            },
            onDelete: (id) => chat.deleteConversation(id),
            onRename: (newTitle) =>
                chat.renameConversation(chat.activeConversation.id, newTitle),
          ),
          body: _ChatLanding(
            onOpenChat: () => _openChatFullScreen(context),
          ),
          floatingActionButton: ChatLauncherFab(
            hasUnread: hasUnread,
            onPressed: () => _openChatFullScreen(context),
            onLongPress: () => _showChatQuickActions(context),
          ),
        );
      },
    );
  }

  Future<void> _openChatFullScreen(BuildContext context) async {
    final chat = AppStateScope.of(context).chat;
    setState(() {
      _lastChatSeenAt = DateTime.now();
      _lastSeenMessageId = chat.activeLastMessageId;
    });
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('POLA Chat'),
            leading: IconButton(
              tooltip: 'Tutup',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          body: const ChatPage(showFeatureHeader: true),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _lastChatSeenAt = DateTime.now();
      _lastSeenMessageId = chat.activeLastMessageId;
    });
  }

  Future<void> _openSettingsSheet(BuildContext context) async {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isCompact = width < 700;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: isCompact ? 0.92 : 0.85,
          minChildSize: isCompact ? 0.65 : 0.55,
          maxChildSize: isCompact ? 0.96 : 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Pengaturan',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: PrimaryScrollController(
                    controller: scrollController,
                    child: const SettingsPage(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChatQuickActions(BuildContext context) async {
    final chat = AppStateScope.of(context).chat;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.bolt),
                title: Text('Chat quick actions'),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('Open chat'),
                onTap: () => Navigator.of(context).pop('open'),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New chat'),
                onTap: () => Navigator.of(context).pop('new'),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Go to settings'),
                onTap: () => Navigator.of(context).pop('settings'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) return;
    switch (action) {
      case 'open':
        await _openChatFullScreen(context);
        break;
      case 'new':
        chat.startNewConversation();
        await _openChatFullScreen(context);
        break;
      case 'settings':
        await _openSettingsSheet(context);
        break;
    }
  }
}

class _ChatLanding extends StatelessWidget {
  const _ChatLanding({required this.onOpenChat});

  final VoidCallback onOpenChat;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ChatFeatureHeader(
              onSelectQuickPrompt: (q) async {
                await chat.sendUserMessage(q);
                onOpenChat();
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onOpenChat,
              icon: const Icon(Icons.chat_bubble_rounded),
              label: const Text('Buka chat'),
            ),
            const SizedBox(height: 12),
            Text(
              'Chat dibuka di layar penuh. Gunakan tombol tutup atau gestur '
              'kembali untuk kembali ke beranda.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _ChatsDrawer extends StatelessWidget {
  const _ChatsDrawer({
    required this.activeId,
    required this.onSelect,
    required this.onNewChat,
    required this.onGoSettings,
    required this.onDelete,
    required this.onRename,
  });

  final String activeId;
  final ValueChanged<String> onSelect;
  final VoidCallback onNewChat;
  final VoidCallback onGoSettings;
  final ValueChanged<String> onDelete;
  final ValueChanged<String> onRename;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final auth = AppStateScope.of(context).auth;
    final convos = chat.conversations;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.school, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POLA - Polibatam Assistant',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedBuilder(
                          animation: auth,
                          builder: (context, _) => Text(
                            auth.isLoggedIn
                                ? auth.email
                                : 'Guest (login optional)',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FilledButton.icon(
                onPressed: onNewChat,
                icon: const Icon(Icons.add),
                label: const Text('New chat'),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: convos.length,
                itemBuilder: (context, index) {
                  final c = convos[index];
                  final selected = c.id == activeId;
                  return ListTile(
                    selected: selected,
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onSelect(c.id),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'rename') {
                          final controller =
                              TextEditingController(text: c.title);
                          final newTitle = await showDialog<String>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Rename chat'),
                                content: TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    labelText: 'New title',
                                  ),
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.of(context)
                                        .pop(controller.text.trim()),
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (newTitle != null && newTitle.isNotEmpty) {
                            onRename(newTitle);
                          }
                        } else if (value == 'delete' && convos.length > 1) {
                          onDelete(c.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'rename',
                          child: Text('Rename'),
                        ),
                        if (convos.length > 1)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings / Profile'),
              onTap: onGoSettings,
            ),
          ],
        ),
      ),
    );
  }
}

