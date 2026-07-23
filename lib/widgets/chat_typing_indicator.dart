import 'package:flutter/material.dart';

/// Indikator animasi saat POLA sedang memproses jawaban.
class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({
    super.key,
    this.label = 'POLA sedang mencari sumber...',
    this.onCancel,
  });

  final String label;
  final VoidCallback? onCancel;

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.label,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.16),
                border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 16,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Row(
                      children: List.generate(3, (i) {
                        final phase = (_controller.value + i * 0.2) % 1.0;
                        final scale = 0.55 + (phase < 0.5 ? phase : 1 - phase);
                        return Padding(
                          padding: EdgeInsets.only(right: i < 2 ? 5 : 0),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (widget.onCancel != null) ...[
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Batalkan',
                visualDensity: VisualDensity.compact,
                onPressed: widget.onCancel,
                icon: Icon(Icons.close_rounded, size: 20, color: cs.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
