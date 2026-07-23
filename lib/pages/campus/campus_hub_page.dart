import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/shell_scope.dart';
import '../../data/campus_announcements.dart';
import '../../ui/theme/pola_colors.dart';
import '../announcements/announcement_detail_page.dart';
import '../announcements/notification_center_page.dart';
import 'campus_search_page.dart';

/// Tab Layanan Kampus — pintasan aksi cepat, bukan katalog artikel.
class CampusHubPage extends StatelessWidget {
  const CampusHubPage({super.key});

  static const _shortcuts = <({
    IconData icon,
    String label,
    String subtitle,
    String prompt,
  })>[
    (
      icon: Icons.school_rounded,
      label: 'KRS & Jadwal',
      subtitle: 'Cara isi KRS, lihat jadwal',
      prompt: 'Bagaimana cara mengisi KRS dan melihat jadwal kuliah di Polibatam?',
    ),
    (
      icon: Icons.calendar_month_rounded,
      label: 'Kalender Akademik',
      subtitle: 'UTS, UAS, libur',
      prompt: 'Kapan periode KRS, UTS, dan UAS semester ini di Polibatam?',
    ),
    (
      icon: Icons.volunteer_activism_rounded,
      label: 'Beasiswa',
      subtitle: 'Syarat & pendaftaran',
      prompt: 'Apa saja beasiswa di Polibatam dan bagaimana cara mendaftar?',
    ),
    (
      icon: Icons.work_outline_rounded,
      label: 'Magang / PKL',
      subtitle: 'Prosedur & mitra',
      prompt: 'Bagaimana prosedur PKL atau magang di Polibatam?',
    ),
    (
      icon: Icons.map_rounded,
      label: 'Lokasi Gedung',
      subtitle: 'Navigasi kampus',
      prompt: 'Di mana lokasi gedung utama dan fasilitas di kampus Polibatam?',
    ),
    (
      icon: Icons.lock_reset_rounded,
      label: 'Bantuan SIA',
      subtitle: 'Login & lupa password',
      prompt: 'Saya kesulitan login SIA Polibatam atau lupa password. Bagaimana solusinya?',
    ),
  ];

  static const _contacts = <({
    IconData icon,
    String label,
    String detail,
    String? copyValue,
  })>[
    (
      icon: Icons.language_rounded,
      label: 'Website resmi',
      detail: 'polibatam.ac.id',
      copyValue: 'https://www.polibatam.ac.id',
    ),
    (
      icon: Icons.school_outlined,
      label: 'Bagian akademik',
      detail: 'KRS, jadwal, surat keterangan',
      copyValue: 'Bagian Akademik Polibatam',
    ),
    (
      icon: Icons.computer_rounded,
      label: 'Helpdesk TI',
      detail: 'Akun SIA, email kampus, Wi‑Fi',
      copyValue: 'Helpdesk TI Polibatam',
    ),
    (
      icon: Icons.security_rounded,
      label: 'Keamanan kampus',
      detail: 'Satpam / darurat di area kampus',
      copyValue: 'Satpam / Keamanan Polibatam',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final announcements = CampusAnnouncements.all.take(3).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Layanan Kampus'),
            actions: [
              IconButton(
                tooltip: 'Cari dengan AI',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CampusSearchPage(),
                  ),
                ),
                icon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Pintasan cepat — ketuk untuk tanya Chatbot POLA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SoftGrid(
              children: [
                for (final s in _shortcuts)
                  _ShortcutTile(
                    icon: s.icon,
                    label: s.label,
                    subtitle: s.subtitle,
                    onTap: () => ShellScope.of(context).openChat(
                      context,
                      chatPrompt: s.prompt,
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Kontak penting',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ShellScope.of(context).openChat(
                      context,
                      chatPrompt: 'Apa kontak bagian akademik dan helpdesk TI Polibatam?',
                    ),
                    child: const Text('Tanya AI'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = _contacts[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            PolaColors.primary.withValues(alpha: 0.12),
                        child: Icon(c.icon, color: PolaColors.primary, size: 22),
                      ),
                      title: Text(
                        c.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(c.detail),
                      trailing: c.copyValue == null
                          ? null
                          : IconButton(
                              tooltip: 'Salin',
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: c.copyValue!),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${c.label} disalin'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                      onTap: () => ShellScope.of(context).openChat(
                        context,
                        chatPrompt:
                            'Jelaskan cara menghubungi ${c.label} di Polibatam.',
                      ),
                    ),
                  );
                },
                childCount: _contacts.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Pengumuman terbaru',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationCenterPage(),
                      ),
                    ),
                    child: const Text('Lihat semua'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final a = announcements[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            PolaColors.secondary.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.campaign_rounded,
                          color: PolaColors.secondary,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        a.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              AnnouncementDetailPage(announcement: a),
                        ),
                      ),
                    ),
                  );
                },
                childCount: announcements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid 2 kolom tanpa SliverGrid aspect-ratio kaku.
class SoftGrid extends StatelessWidget {
  const SoftGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rows = <Widget>[];
          for (var i = 0; i < children.length; i += 2) {
            final left = children[i];
            final right = i + 1 < children.length ? children[i + 1] : null;
            rows.add(
              Padding(
                padding: EdgeInsets.only(bottom: i + 2 < children.length ? 12 : 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 12),
                    Expanded(child: right ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            );
          }
          return Column(children: rows);
        },
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: PolaColors.primary.withValues(alpha: 0.12),
                child: Icon(icon, color: PolaColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: PolaColors.primary.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tanya AI',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PolaColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
