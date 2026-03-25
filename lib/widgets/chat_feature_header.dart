import 'package:flutter/material.dart';

class ChatFeatureHeader extends StatelessWidget {
  const ChatFeatureHeader({super.key, required this.onSelectQuickPrompt});

  final ValueChanged<String> onSelectQuickPrompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POLA - Polibatam Assistant',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Tanya seputar PBL, lab, beasiswa, peraturan akademik, dan kehidupan kampus.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FeatureCard(
                icon: Icons.groups,
                title: 'PBL & Tim Proyek',
                subtitle: 'Cari rekan tim lintas jurusan dan atur milestone.',
                color: Colors.blue[50],
                onTap: () => onSelectQuickPrompt(
                  'Saya ingin mengatur proyek PBL (Project Based Learning). '
                  'Tolong bantu: (1) rekomendasi struktur milestone, '
                  '(2) saran pembagian peran tim lintas jurusan, '
                  '(3) checklist laporan akhir PBL.',
                ),
              ),
              _FeatureCard(
                icon: Icons.science,
                title: 'Lab & Fasilitas',
                subtitle: 'Cek ketersediaan lab dan panduan alat.',
                color: Colors.green[50],
                onTap: () => onSelectQuickPrompt(
                  'Tolong bantu saya soal fasilitas kampus: '
                  'cara meminjam lab, status ketersediaan lab teknis, '
                  'dan panduan singkat penggunaan alat di lab Polibatam.',
                ),
              ),
              _FeatureCard(
                icon: Icons.school,
                title: 'Beasiswa & Magang',
                subtitle: 'Info beasiswa dan magang mitra Polibatam.',
                color: Colors.orange[50],
                onTap: () => onSelectQuickPrompt(
                  'Saya ingin informasi beasiswa internal dan magang '
                  'yang bekerja sama dengan Polibatam. Tolong jelaskan '
                  'syarat umum, cara daftar, dan contoh perusahaan mitra.',
                ),
              ),
              _FeatureCard(
                icon: Icons.menu_book,
                title: 'Peraturan Akademik',
                subtitle: 'FAQ kehadiran, cuti, ujian, dan lain-lain.',
                color: Colors.purple[50],
                onTap: () => onSelectQuickPrompt(
                  'Jelaskan secara ringkas peraturan akademik penting di Polibatam: '
                  'batas minimal kehadiran UAS, prosedur cuti akademik, dan aturan remedial.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SuggestionChips(onSelect: onSelectQuickPrompt),
      ],
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final suggestions = <String>[
      'Jadwal kuliah dan PBL saya minggu ini bagaimana?',
      'Apa saja beasiswa internal Polibatam yang masih dibuka?',
      'Bagaimana prosedur peminjaman Lab untuk PBL?',
      'Bagaimana prosedur cuti akademik di Polibatam?',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions
          .map(
            (s) => ActionChip(
              label: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
              onPressed: () => onSelect(s),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(icon, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style:
                      textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

