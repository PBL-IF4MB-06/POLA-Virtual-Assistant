import 'package:flutter/material.dart';

import '../../app/shell_scope.dart';
import '../../data/popular_questions.dart';
import '../../ui/theme/pola_colors.dart';

class CampusSearchPage extends StatefulWidget {
  const CampusSearchPage({super.key});

  @override
  State<CampusSearchPage> createState() => _CampusSearchPageState();
}

class _CampusSearchPageState extends State<CampusSearchPage> {
  final _controller = TextEditingController();

  static const _categories = <({IconData icon, String label, String prompt})>[
    (icon: Icons.person_search_rounded, label: 'Dosen', prompt: 'Cari informasi dosen di Polibatam: '),
    (icon: Icons.apartment_rounded, label: 'Gedung', prompt: 'Lokasi gedung di kampus Polibatam: '),
    (icon: Icons.volunteer_activism_rounded, label: 'Beasiswa', prompt: 'Informasi beasiswa Polibatam: '),
    (icon: Icons.schedule_rounded, label: 'Jadwal', prompt: 'Jadwal kuliah Polibatam: '),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ask(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    Navigator.of(context).pop();
    ShellScope.of(context).goToTab(ShellTab.chat, chatPrompt: q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Campus Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: _ask,
            decoration: InputDecoration(
              hintText: 'Cari dosen, gedung, beasiswa…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                icon: const Icon(Icons.auto_awesome_rounded, color: PolaColors.primary),
                onPressed: () => _ask(_controller.text),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Kategori', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _categories)
                ActionChip(
                  avatar: Icon(c.icon, size: 18),
                  label: Text(c.label),
                  onPressed: () => _ask('${c.prompt}Polibatam'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Rekomendasi AI',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final q in PopularQuestions.all.take(5))
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.trending_up_rounded, color: PolaColors.primary),
                title: Text(q.question),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => _ask(q.question),
              ),
            ),
        ],
      ),
    );
  }
}
