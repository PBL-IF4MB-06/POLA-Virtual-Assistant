import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/pola_empty_state.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  static String _emojiForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('krs')) return '📚';
    if (t.contains('beasiswa')) return '🎓';
    if (t.contains('uas') || t.contains('uts')) return '📢';
    if (t.contains('pkl') || t.contains('magang')) return '💼';
    return '💬';
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final settings = AppStateScope.of(context).settings;

    return AnimatedBuilder(
      animation: Listenable.merge([chat, settings]),
      builder: (context, _) {
        final convos = chat.conversations;
        final privacy = settings.privacyMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Chat'),
            actions: [
              if (convos.isNotEmpty)
                TextButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus semua?'),
                        content: const Text(
                          'Semua percakapan chatbot akan dihapus dari perangkat ini.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) chat.clearAllConversations();
                  },
                  child: const Text('Hapus'),
                ),
            ],
          ),
          body: convos.isEmpty
              ? PolaEmptyState(
                  icon: Icons.forum_outlined,
                  title: 'Belum ada percakapan',
                  message:
                      'Mulai bertanya ke chatbot POLA — riwayat akan tersimpan otomatis di sini.',
                  actionLabel: 'Mulai Chat',
                  onAction: () {
                    Navigator.of(context).pop();
                    ShellScope.of(context).goToTab(ShellTab.chat);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: convos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final c = convos[i];
                    final title = privacy ? 'Percakapan ••••' : c.title;
                    return Card(
                      child: ListTile(
                        leading: Text(
                          _emojiForTitle(c.title),
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(_relativeTime(c.lastMessage?.createdAt)),
                        trailing: const Icon(Icons.chevron_right, color: PolaColors.primary),
                        onTap: () {
                          chat.setActiveConversation(c.id);
                          ShellScope.of(context).goToTab(ShellTab.chat);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
