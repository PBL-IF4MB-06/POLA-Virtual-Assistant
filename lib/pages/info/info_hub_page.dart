import 'package:flutter/material.dart';

import '../../data/campus_catalog.dart';
import 'info_detail_page.dart';

class InfoHubPage extends StatelessWidget {
  const InfoHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Informasi'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (final cat in CampusInfoCategory.values) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 10),
              child: Text(
                CampusCatalog.categoryLabel(cat),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            ...CampusCatalog.byCategory(cat).map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _InfoTile(
                  module: m,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => InfoDetailPage(module: m),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.module, required this.onTap});

  final CampusInfoModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primary.withValues(alpha: 0.14),
          child: Icon(module.icon, color: cs.primary),
        ),
        title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(module.subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
