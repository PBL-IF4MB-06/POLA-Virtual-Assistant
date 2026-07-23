import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../app/shell_scope.dart';
import '../../data/campus_announcements.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/pola_empty_state.dart';
import '../settings_page.dart';
import 'announcement_detail_page.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = AppStateScope.of(context).notifications;
    final settings = AppStateScope.of(context).settings;
    final items = CampusAnnouncements.all;

    return AnimatedBuilder(
      animation: Listenable.merge([notifications, settings]),
      builder: (context, _) {
        if (!settings.notificationsEnabled) {
          return Scaffold(
            appBar: AppBar(title: const Text('Notifikasi')),
            body: PolaEmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Notifikasi dimatikan',
              message:
                  'Aktifkan notifikasi di Pengaturan untuk melihat pengumuman kampus.',
              actionLabel: 'Buka Pengaturan',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
              ),
            ),
          );
        }

        final unread = notifications.unreadCount(items.map((a) => a.id));

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(unread > 0 ? 'Notifikasi ($unread)' : 'Notifikasi'),
            actions: [
              if (items.isNotEmpty && unread > 0)
                TextButton(
                  onPressed: () async {
                    await notifications.markAllAsRead(items.map((a) => a.id));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Semua ditandai dibaca.')),
                      );
                    }
                  },
                  child: const Text('Tandai dibaca'),
                ),
            ],
          ),
          body: items.isEmpty
              ? const PolaEmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'Belum ada pengumuman',
                  message: 'Pengumuman kampus akan muncul di sini.',
                )
              : RefreshIndicator(
                  onRefresh: () => Future<void>.delayed(const Duration(milliseconds: 500)),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final a = items[i];
                      final isNew = !notifications.isRead(a.id);
                      return Dismissible(
                        key: ValueKey(a.id),
                        direction: isNew
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: PolaColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.done_all_rounded, color: PolaColors.success),
                              SizedBox(width: 8),
                              Text(
                                'Tandai dibaca',
                                style: TextStyle(
                                  color: PolaColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (_) async {
                          await notifications.markAsRead(a.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${a.title} ditandai dibaca.')),
                            );
                          }
                          return false;
                        },
                        child: _NotificationCard(
                          announcement: a,
                          isNew: isNew,
                          onMarkRead: isNew
                              ? () => notifications.markAsRead(a.id)
                              : null,
                          onMarkUnread: !isNew
                              ? () => notifications.markAsUnread(a.id)
                              : null,
                          onTap: () async {
                            await notifications.markAsRead(a.id);
                            if (!context.mounted) return;
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    AnnouncementDetailPage(announcement: a),
                              ),
                            );
                          },
                          onAsk: () => ShellScope.of(context).openChat(
                            context,
                            chatPrompt: 'Jelaskan pengumuman: ${a.title}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.announcement,
    required this.isNew,
    required this.onTap,
    required this.onAsk,
    this.onMarkRead,
    this.onMarkUnread,
  });

  final CampusAnnouncement announcement;
  final bool isNew;
  final VoidCallback onTap;
  final VoidCallback onAsk;
  final VoidCallback? onMarkRead;
  final VoidCallback? onMarkUnread;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final emoji = switch (announcement.type) {
      AnnouncementType.akademik => '📢',
      AnnouncementType.beasiswa => '🎓',
      AnnouncementType.lomba => '🏆',
      AnnouncementType.seminar => '📅',
    };

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: PolaColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            announcement.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: PolaColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'Baru',
                              style: TextStyle(
                                color: PolaColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                          onSelected: (v) {
                            if (v == 'read') onMarkRead?.call();
                            if (v == 'unread') onMarkUnread?.call();
                          },
                          itemBuilder: (context) => [
                            if (onMarkRead != null)
                              const PopupMenuItem(
                                value: 'read',
                                child: Text('Tandai dibaca'),
                              ),
                            if (onMarkUnread != null)
                              const PopupMenuItem(
                                value: 'unread',
                                child: Text('Tandai belum dibaca'),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onAsk,
                      icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                      label: const Text('Tanya Chatbot'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
