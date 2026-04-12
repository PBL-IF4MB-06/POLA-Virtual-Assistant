import 'package:flutter/material.dart';

class ChatFeatureHeader extends StatelessWidget {
  const ChatFeatureHeader({super.key, required this.onSelectQuickPrompt});

  final ValueChanged<String> onSelectQuickPrompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withValues(alpha: 0.85),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.45),
                ),
              ),
              child: Icon(Icons.smart_toy_outlined, size: 18, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.surface.withValues(alpha: 0.85),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  'Halo, ada yang bisa saya bantu?',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surface.withValues(alpha: 0.82),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          ),
          child: Text(
            'Selamat datang di Polibatam Assistant.\n'
            'Saya POLA, AI asisten virtual Polibatam.\n'
            'Silakan tanyakan pertanyaan seputar kampus Polibatam, seperti beasiswa, akademik, jurusan, laboratorium, atau magang.',
            style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Quick Prompts',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _QuickPrompt(
              icon: Icons.school_outlined,
              label: 'Beasiswa',
              onTap: () => onSelectQuickPrompt(
                'Berikut adalah informasi beasiswa di Polibatam.',
              ),
            ),
            _QuickPrompt(
              icon: Icons.menu_book_outlined,
              label: 'Akademik',
              onTap: () => onSelectQuickPrompt(
                'Ringkas peraturan akademik penting (kehadiran, cuti, remedial) dan cantumkan sumber.',
              ),
            ),
            _QuickPrompt(
              icon: Icons.apartment_outlined,
              label: 'Jurusan',
              onTap: () => onSelectQuickPrompt(
                'Apa saja jurusan/prodi yang tersedia di Polibatam? Sertakan sumber.',
              ),
            ),
            _QuickPrompt(
              icon: Icons.science_outlined,
              label: 'Laboratorium',
              onTap: () => onSelectQuickPrompt(
                'Bagaimana prosedur peminjaman lab? Sertakan aturan dan sumber.',
              ),
            ),
            _QuickPrompt(
              icon: Icons.work_outline,
              label: 'Magang',
              onTap: () => onSelectQuickPrompt(
                'Info magang/MBKM terkait Polibatam: alur, syarat, dan sumber.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickPrompt extends StatelessWidget {
  const _QuickPrompt({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: cs.surface.withValues(alpha: 0.82),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

