import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../ui/theme/pola_tokens.dart';
import '../ui/widgets/pola_background.dart';
import 'chat_page.dart';

class CopilotPage extends StatelessWidget {
  const CopilotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        final title = chat.activeConversation.title;
        final suggestions = chat.followUpSuggestions;
        return PolaBackground(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                child: _TopBar(
                  title: title,
                  onNew: chat.startNewConversation,
                  onClear: chat.clearAllConversations,
                ),
              ),
              if (suggestions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final s in suggestions.take(6))
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(
                                s,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () => chat.sendUserMessage(s),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: ChatPage(
                  showFeatureHeader: false,
                  emptyHint:
                      'Tanyakan seputar Polibatam. Web (Google CSE) hanya dipakai jika Anda menyebut Polibatam di pertanyaan.',
                ),
              ),
              const SizedBox(height: PolaTokens.r12),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onNew,
    required this.onClear,
  });

  final String title;
  final VoidCallback onNew;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withValues(alpha: 0.95),
                cs.tertiary.withValues(alpha: 0.75),
              ],
            ),
          ),
          child: Icon(Icons.auto_awesome, color: cs.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Copilot',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        _PillButton(icon: Icons.add, tooltip: 'New', onTap: onNew),
        const SizedBox(width: 8),
        _PillButton(
          icon: Icons.delete_sweep_outlined,
          tooltip: 'Clear',
          onTap: onClear,
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: cs.surface.withValues(alpha: 0.45),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

