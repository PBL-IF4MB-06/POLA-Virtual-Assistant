import 'package:flutter/material.dart';

class ChatQuickPrompt {
  const ChatQuickPrompt({
    required this.icon,
    required this.label,
    required this.prompt,
  });

  final IconData icon;
  final String label;
  final String prompt;
}

/// Chip pertanyaan cepat untuk memulai percakapan (empty state).
class ChatQuickPrompts extends StatelessWidget {
  const ChatQuickPrompts({
    super.key,
    required this.onSelect,
    this.prompts = defaultPrompts,
  });

  final ValueChanged<String> onSelect;
  final List<ChatQuickPrompt> prompts;

  static const defaultPrompts = <ChatQuickPrompt>[
    ChatQuickPrompt(
      icon: Icons.edit_note_rounded,
      label: 'KRS',
      prompt: 'Kapan jadwal KRS semester ini di Polibatam?',
    ),
    ChatQuickPrompt(
      icon: Icons.work_outline_rounded,
      label: 'PKL',
      prompt: 'Bagaimana prosedur PKL/magang di Polibatam?',
    ),
    ChatQuickPrompt(
      icon: Icons.volunteer_activism_rounded,
      label: 'Beasiswa',
      prompt: 'Apa syarat beasiswa di Polibatam?',
    ),
    ChatQuickPrompt(
      icon: Icons.apartment_rounded,
      label: 'Gedung TI',
      prompt: 'Di mana lokasi Gedung TI di kampus Polibatam?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mulai dengan pertanyaan ini',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in prompts)
                ActionChip(
                  avatar: Icon(p.icon, size: 18, color: cs.primary),
                  label: Text(p.label),
                  onPressed: () => onSelect(p.prompt),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
