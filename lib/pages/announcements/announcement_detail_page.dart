import 'package:flutter/material.dart';

import '../../app/app_state_scope.dart';
import '../../data/campus_announcements.dart';
import '../../widgets/campus/ask_pola_button.dart';

class AnnouncementDetailPage extends StatefulWidget {
  const AnnouncementDetailPage({super.key, required this.announcement});

  final CampusAnnouncement announcement;

  @override
  State<AnnouncementDetailPage> createState() => _AnnouncementDetailPageState();
}

class _AnnouncementDetailPageState extends State<AnnouncementDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppStateScope.of(context).notifications.markAsRead(widget.announcement.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    final d = announcement.date;
    final date = '${d.day}/${d.month}/${d.year}';
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Chip(
            avatar: Icon(CampusAnnouncements.typeIcon(announcement.type), size: 18),
            label: Text(CampusAnnouncements.typeLabel(announcement.type)),
          ),
          const SizedBox(height: 12),
          Text(
            announcement.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                announcement.body,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AskPolaButton(
            prompt:
                'Jelaskan detail pengumuman: "${announcement.title}" di Polibatam.',
          ),
        ],
      ),
    );
  }
}
