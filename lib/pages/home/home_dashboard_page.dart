import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../data/campus_announcements.dart';
import '../../data/popular_questions.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/pola_search_bar.dart';
import '../announcements/announcement_detail_page.dart';

/// Beranda ringkas untuk demo PBL — semua tombol terhubung ke chatbot.
class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppStateScope.of(context).auth;
    final chat = AppStateScope.of(context).chat;
    final settings = AppStateScope.of(context).settings;

    return AnimatedBuilder(
      animation: Listenable.merge([auth, chat, settings]),
      builder: (context, _) {
        final name = settings.profileName.isNotEmpty
            ? settings.profileName.split(' ').first
            : auth.displayName.split(' ').first;

        void askChat(String prompt) =>
            ShellScope.of(context).goToTab(ShellTab.chat, chatPrompt: prompt);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PolaColors.primary, PolaColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: PolaColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Implementasi Chatbot AI — POLA Mobile',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Halo, $name 👋',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tanya informasi kampus lewat chatbot AI',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PolaSearchBar(
                      onTap: () => ShellScope.of(context).goToTab(ShellTab.chat),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aksi Cepat',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _QuickActions(onChat: askChat),
                    const SizedBox(height: 24),
                    Text(
                      'Contoh Pertanyaan Chatbot',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                    ...PopularQuestions.all.take(4).map(
                          (q) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.chat_bubble_outline,
                                  color: PolaColors.primary),
                              title: Text(q.question,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => askChat(q.question),
                            ),
                          ),
                        ),
                    const SizedBox(height: 16),
                    Text(
                      'Pengumuman Kampus',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: CampusAnnouncements.all.take(3).length,
                  itemBuilder: (context, i) {
                    final a = CampusAnnouncements.all[i];
                    return SizedBox(
                      width: 280,
                      child: Card(
                        margin: const EdgeInsets.only(right: 10),
                        child: ListTile(
                          title: Text(a.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(a.summary,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => AnnouncementDetailPage(announcement: a),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Riwayat Chat',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => ShellScope.of(context).goToTab(ShellTab.chat),
                          child: const Text('Buka Chatbot'),
                        ),
                      ],
                    ),
                    if (chat.conversations.isEmpty)
                      Text(
                        'Belum ada percakapan. Mulai tanya di tab Chatbot.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      ...chat.conversations.take(3).map(
                            (c) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.forum_outlined,
                                    color: PolaColors.primary),
                                title: Text(c.title,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  _relativeTime(c.lastMessage?.createdAt),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  chat.setActiveConversation(c.id);
                                  ShellScope.of(context).goToTab(ShellTab.chat);
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static String _relativeTime(DateTime? dt) {
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.onChat});

  final void Function(String) onChat;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('📅', 'Kalender Akademik', () => onChat('Kalender akademik Polibatam semester ini?')),
      ('🎓', 'Beasiswa', () => onChat('Informasi beasiswa di Polibatam?')),
      ('📚', 'Jadwal Kuliah', () => onChat('Bagaimana cara cek jadwal kuliah Polibatam?')),
      ('🏫', 'Jurusan', () => onChat('Jurusan apa saja yang ada di Polibatam?')),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        for (final (emoji, label, tap) in items)
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: tap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
