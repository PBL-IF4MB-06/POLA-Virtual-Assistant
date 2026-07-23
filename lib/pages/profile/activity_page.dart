import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../widgets/pola_empty_state.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final bookmarks = AppStateScope.of(context).bookmarks;
    final settings = AppStateScope.of(context).settings;

    return AnimatedBuilder(
      animation: Listenable.merge([chat, bookmarks, settings]),
      builder: (context, _) {
        final privacy = settings.privacyMode;
        final activities = <({String title, String subtitle, IconData icon, DateTime? when})>[];

        for (final c in chat.conversations) {
          final last = c.lastMessage;
          if (last != null) {
            activities.add((
              title: privacy ? 'Percakapan' : c.title,
              subtitle: privacy
                  ? '••••••••'
                  : (last.text.trim().isEmpty ? 'Percakapan chatbot' : last.text.trim()),
              icon: Icons.chat_bubble_outline,
              when: last.createdAt,
            ));
          }
        }

        for (final b in bookmarks.items) {
          activities.add((
            title: 'Bookmark disimpan',
            subtitle: privacy ? '••••••••' : b.text,
            icon: Icons.bookmark_added_outlined,
            when: b.savedAt,
          ));
        }

        activities.sort((a, b) {
          final aw = a.when ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bw = b.when ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bw.compareTo(aw);
        });

        return Scaffold(
          appBar: AppBar(title: const Text('Riwayat Aktivitas')),
          body: activities.isEmpty
              ? PolaEmptyState(
                  icon: Icons.timeline_outlined,
                  title: 'Belum ada aktivitas',
                  message:
                      'Aktivitas chatbot dan bookmark Anda akan muncul di sini.',
                  actionLabel: 'Mulai Chat',
                  onAction: () {
                    Navigator.of(context).pop();
                    ShellScope.of(context).goToTab(ShellTab.chat);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final a = activities[i];
                    final when = a.when;
                    final time = when == null
                        ? ''
                        : '${when.day}/${when.month}/${when.year} '
                            '${when.hour.toString().padLeft(2, '0')}:'
                            '${when.minute.toString().padLeft(2, '0')}';
                    return Card(
                      child: ListTile(
                        leading: Icon(a.icon),
                        title: Text(
                          a.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${a.subtitle}\n$time',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
