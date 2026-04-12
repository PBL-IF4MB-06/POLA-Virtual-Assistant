import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../ui/theme/pola_tokens.dart';
import '../ui/widgets/pola_background.dart';
import '../widgets/pola_logo.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onOpenCopilot,
  });

  final VoidCallback onOpenCopilot;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        final convos = chat.conversations;
        return PolaBackground(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: const PolaLogo(size: 48),
                actions: [
                  _PillIconButton(
                    tooltip: 'Buka Copilot',
                    onPressed: onOpenCopilot,
                    icon: Icons.chat_bubble_rounded,
                  ),
                  const SizedBox(width: 8),
                  _PillIconButton(
                    tooltip: 'New chat',
                    onPressed: chat.startNewConversation,
                    icon: Icons.add,
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: PolaTokens.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        onOpenCopilot: onOpenCopilot,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Quick actions',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      _QuickGrid(
                        onAsk: (q) async {
                          await chat.sendUserMessage(q);
                          onOpenCopilot();
                        },
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Recent chats',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          TextButton(
                            onPressed: chat.clearAllConversations,
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                sliver: SliverList.separated(
                  itemCount: convos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = convos[index];
                    final last = c.lastMessage?.text.trim() ?? '';
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        chat.setActiveConversation(c.id);
                        onOpenCopilot();
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: cs.surface.withValues(alpha: 0.55),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: cs.primary.withValues(alpha: 0.22),
                              foregroundColor: cs.onSurface,
                              child: const Icon(Icons.forum_rounded),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    last.isEmpty ? 'No messages yet' : last,
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
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PillIconButton extends StatelessWidget {
  const _PillIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: cs.surface.withValues(alpha: 0.45),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onOpenCopilot});

  final VoidCallback onOpenCopilot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.16),
            cs.secondary.withValues(alpha: 0.12),
            cs.surface.withValues(alpha: 0.90),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
        boxShadow: PolaTokens.softShadow(Colors.black),
      ),
      child: Row(
        children: [
          const PolaLogo(size: 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POLA (Polibatam Assistant)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Asisten kampus untuk beasiswa, akademik, jurusan, jadwal, dan fasilitas — lengkap dengan sources.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onOpenCopilot,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Mulai Tanya Jawab'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickGrid extends StatelessWidget {
  const _QuickGrid({required this.onAsk});

  final Future<void> Function(String question) onAsk;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = <({IconData icon, String title, String prompt})>[
      (
        icon: Icons.calendar_month_rounded,
        title: 'Jadwal & PBL',
        prompt:
            'Tolong jelaskan cara cek jadwal kuliah dan alur PBL di Polibatam, sertakan sumber resmi jika ada.',
      ),
      (
        icon: Icons.school_rounded,
        title: 'Beasiswa',
        prompt:
            'Beasiswa apa saja yang tersedia untuk mahasiswa Polibatam? Sertakan sumber dan link.',
      ),
      (
        icon: Icons.science_rounded,
        title: 'Lab & alat',
        prompt:
            'Bagaimana prosedur peminjaman lab di Polibatam? Sertakan aturan dan sumber.',
      ),
      (
        icon: Icons.policy_rounded,
        title: 'Akademik',
        prompt:
            'Ringkas peraturan akademik penting (kehadiran, cuti, remedial) dan cantumkan sumber.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, i) {
        final it = items[i];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onAsk(it.prompt),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cs.surface,
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
              boxShadow: PolaTokens.softShadow(Colors.black),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primaryContainer,
                  ),
                  child: Icon(it.icon, color: cs.onPrimaryContainer),
                ),
                const Spacer(),
                Text(
                  it.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to ask',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

