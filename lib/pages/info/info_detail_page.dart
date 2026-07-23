import 'package:flutter/material.dart';

import '../../data/campus_catalog.dart';
import '../../ui/theme/pola_colors.dart';
import '../../widgets/campus/ask_pola_button.dart';

class InfoDetailPage extends StatelessWidget {
  const InfoDetailPage({super.key, required this.module});

  final CampusInfoModule module;

  @override
  Widget build(BuildContext context) {
    final isBeasiswa = module.id == 'beasiswa';

    return Scaffold(
      appBar: AppBar(title: Text(module.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            color: PolaColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(module.icon, size: 36, color: Colors.white),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              module.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            Text(
                              module.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (isBeasiswa) ...[
                    const SizedBox(height: 16),
                    _HeroMeta(label: 'Deadline', value: '31 Maret 2026'),
                    const SizedBox(height: 8),
                    _HeroMeta(label: 'Persyaratan', value: 'IPK min. 3.50, surat rekomendasi'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final s in module.sections) ...[
            Text(
              s.heading,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(s.body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55)),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AskPolaButton(prompt: module.chatPrompt, label: 'Tanya AI'),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      ],
    );
  }
}
