import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/pola_empty_state.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = AppStateScope.of(context).bookmarks;
    final settings = AppStateScope.of(context).settings;

    return AnimatedBuilder(
      animation: Listenable.merge([bookmarks, settings]),
      builder: (context, _) {
        final items = bookmarks.items;
        final privacy = settings.privacyMode;
        return Scaffold(
          appBar: AppBar(title: const Text('Bookmark')),
          body: items.isEmpty
              ? PolaEmptyState(
                  emoji: '⭐',
                  icon: Icons.bookmark_outline,
                  title: 'Belum ada bookmark',
                  message:
                      'Simpan jawaban chatbot favorit dengan mengetuk ikon bintang pada balasan POLA.',
                  actionLabel: 'Mulai Chat',
                  onAction: () {
                    Navigator.of(context).pop();
                    ShellScope.of(context).goToTab(ShellTab.chat);
                  },
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final b = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Text('⭐', style: TextStyle(fontSize: 26)),
                        title: Text(
                          b.conversationTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          privacy ? '••••••••' : b.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: PolaColors.primary),
                          onPressed: () => bookmarks.remove(b.messageId),
                        ),
                        onTap: () {
                          ShellScope.of(context).openChat(
                            context,
                            chatPrompt: b.text,
                          );
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
