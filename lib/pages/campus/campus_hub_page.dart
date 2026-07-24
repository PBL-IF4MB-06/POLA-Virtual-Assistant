import 'package:flutter/material.dart';

import '../../app/shell_scope.dart';
import '../../data/campus_catalog.dart';
import '../../ui/theme/pola_colors.dart';
import '../info/info_detail_page.dart';
import 'campus_search_page.dart';

class CampusHubPage extends StatelessWidget {
  const CampusHubPage({super.key});

  static const _gridItems = <({String emoji, String label, String moduleId})>[
    (emoji: '🎓', label: 'Akademik', moduleId: 'informasi_krs'),
    (emoji: '📅', label: 'Kalender', moduleId: 'kalender_akademik'),
    (emoji: '📢', label: 'Pengumuman', moduleId: 'faq'),
    (emoji: '💰', label: 'Beasiswa', moduleId: 'beasiswa'),
    (emoji: '💼', label: 'Magang', moduleId: 'pkl_magang'),
    (emoji: '🏆', label: 'Prestasi', moduleId: 'ukm'),
    (emoji: '📍', label: 'Peta Kampus', moduleId: 'peta_kampus'),
    (emoji: '👨‍🏫', label: 'Dosen', moduleId: 'direktori_dosen'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: const Text('Pusat Kampus POLA'),
            actions: [
              IconButton(
                tooltip: 'Pencarian Kampus AI',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CampusSearchPage()),
                ),
                icon: const Icon(Icons.travel_explore_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _AiSearchBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const CampusSearchPage()),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = _gridItems[i];
                  final module = CampusCatalog.byId(item.moduleId);
                  return _CampusGridCard(
                    emoji: item.emoji,
                    label: item.label,
                    onTap: () {
                      if (module != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => InfoDetailPage(module: module),
                          ),
                        );
                      } else {
                        ShellScope.of(context).goToTab(
                          ShellTab.chat,
                          chatPrompt: 'Informasi tentang ${item.label} di Polibatam',
                        );
                      }
                    },
                  );
                },
                childCount: _gridItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _AiSearchBanner extends StatelessWidget {
  const _AiSearchBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PolaColors.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.travel_explore_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencarian Kampus AI',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Cari dosen, gedung, beasiswa, jadwal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampusGridCard extends StatelessWidget {
  const _CampusGridCard({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
