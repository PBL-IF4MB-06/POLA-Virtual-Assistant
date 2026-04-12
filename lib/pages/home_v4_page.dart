import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';

class HomeV4Page extends StatelessWidget {
  const HomeV4Page({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chat = AppStateScope.of(context).chat;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary,
                    cs.tertiary.withValues(alpha: 0.88),
                  ],
                ),
              ),
              child: Icon(Icons.bolt_rounded, color: cs.onPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'POLA v4',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Reset total UI • Copilot dengan sources',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'New chat',
              onPressed: chat.startNewConversation,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mulai Copilot',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Hanya topik Polibatam: knowledge lokal dulu, lalu web jika Anda menyebut Polibatam.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _PromptChip(
                      icon: Icons.school_rounded,
                      label: 'Akademik',
                      prompt:
                          'Ringkas aturan akademik penting (kehadiran, cuti, remedial) dan cantumkan sumber.',
                      onAsk: (q) => chat.sendUserMessage(q),
                    ),
                    _PromptChip(
                      icon: Icons.event_available_rounded,
                      label: 'Jadwal',
                      prompt:
                          'Bagaimana cara cek jadwal kuliah dan info terbaru kampus? Sertakan sumber.',
                      onAsk: (q) => chat.sendUserMessage(q),
                    ),
                    _PromptChip(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin',
                      prompt:
                          'Apa saja fitur admin di aplikasi ini dan bagaimana cara memakainya?',
                      onAsk: (q) => chat.sendUserMessage(q),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      // Tab pindah di shell; di sini cukup scroll user ke tab Chat.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Buka tab Chat untuk melihat percakapan.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text('Buka Tab Chat'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Recent',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: chat,
          builder: (context, _) {
            final convos = chat.conversations.take(6).toList();
            if (convos.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Belum ada chat. Tekan tombol + untuk mulai.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final c in convos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cs.primary.withValues(alpha: 0.18),
                          child: const Icon(Icons.forum_rounded),
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
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => chat.setActiveConversation(c.id),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({
    required this.icon,
    required this.label,
    required this.prompt,
    required this.onAsk,
  });

  final IconData icon;
  final String label;
  final String prompt;
  final void Function(String) onAsk;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => onAsk(prompt),
    );
  }
}

