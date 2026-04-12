import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'chat_page.dart';
import 'chat_search_delegate.dart';

class CopilotV4Page extends StatelessWidget {
  const CopilotV4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Copilot',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          chat.activeConversation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Search',
                    onPressed: () async {
                      final convo = chat.activeConversation;
                      await showSearch(
                        context: context,
                        delegate: ChatSearchDelegate(messages: convo.messages),
                      );
                    },
                    icon: const Icon(Icons.search),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'New',
                    onPressed: chat.startNewConversation,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            if (chat.followUpSuggestions.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final s = chat.followUpSuggestions[i];
                    return ActionChip(
                      label: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () => chat.sendUserMessage(s),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemCount: chat.followUpSuggestions.take(8).length,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ChatPage(
                showFeatureHeader: true,
                emptyHint:
                    'Mulai dari pertanyaan spesifik. POLA akan kasih jawaban + sources.',
              ),
            ),
          ],
        );
      },
    );
  }
}

