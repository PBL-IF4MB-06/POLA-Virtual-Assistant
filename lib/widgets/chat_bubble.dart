import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';
import 'formatted_message_text.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onFeedback,
    this.onRetry,
    this.onBookmark,
    this.isBookmarked = false,
    this.onRegenerate,
  });

  final ChatMessage message;
  final void Function(MessageFeedback feedback)? onFeedback;
  final VoidCallback? onRetry;
  final VoidCallback? onBookmark;
  final bool isBookmarked;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final isError = message.isError;
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);
    final timeColor = isError
        ? colorScheme.error.withValues(alpha: 0.75)
        : isUser
            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.68)
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
    final hasAttachments = message.attachments.isNotEmpty;
    final hasSources = !isUser && message.sources.isNotEmpty;
    final hasRoutes = !isUser && message.routes.isNotEmpty;
    final bubbleColor = isError
        ? colorScheme.errorContainer.withValues(alpha: 0.55)
        : isUser
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final bubbleFg = isError
        ? colorScheme.onErrorContainer
        : isUser
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSurface;
    final bubbleBorder = isError
        ? colorScheme.error.withValues(alpha: 0.35)
        : isUser
            ? colorScheme.primary.withValues(alpha: 0.28)
            : colorScheme.outlineVariant.withValues(alpha: 0.28);

    return Semantics(
      label: isUser
          ? 'Pesan Anda: ${message.text}'
          : isError
              ? 'Pesan error: ${message.text}'
              : 'Jawaban POLA: ${message.text}',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _BotAvatar(colorScheme: colorScheme, isError: isError),
              if (!isUser) const SizedBox(width: 10),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showActions(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 10),
                        bottomRight: Radius.circular(isUser ? 10 : 18),
                      ),
                      border: Border.all(color: bubbleBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasAttachments) ...[
                          _AttachmentsGrid(attachments: message.attachments),
                          const SizedBox(height: 10),
                        ],
                        if (isError)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FormattedMessageText(
                                  text: message.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: bubbleFg,
                                        height: 1.32,
                                      ),
                                ),
                              ),
                            ],
                          )
                        else
                          FormattedMessageText(
                            text: message.text,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: bubbleFg,
                                  height: 1.32,
                                ),
                          ),
                        if (hasSources) ...[
                          const SizedBox(height: 10),
                          _SourcesSection(sources: message.sources),
                        ],
                        if (hasRoutes) ...[
                          const SizedBox(height: 10),
                          _RoutesSection(routes: message.routes),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (!isUser && onBookmark != null && !isError) ...[
                              IconButton(
                                tooltip: isBookmarked
                                    ? 'Hapus bookmark'
                                    : 'Simpan jawaban',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: onBookmark,
                                icon: Icon(
                                  isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_outline_rounded,
                                  size: 18,
                                  color: isBookmarked
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (!isUser && onRegenerate != null && !isError)
                              IconButton(
                                tooltip: 'Regenerate',
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                onPressed: onRegenerate,
                                icon: Icon(Icons.refresh_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                              ),
                            if (!isUser && onFeedback != null && !isError) ...[
                              _FeedbackButton(
                                icon: Icons.thumb_up_outlined,
                                selectedIcon: Icons.thumb_up,
                                selected:
                                    message.feedback == MessageFeedback.positive,
                                tooltip: 'Membantu',
                                onTap: () =>
                                    onFeedback!(MessageFeedback.positive),
                              ),
                              _FeedbackButton(
                                icon: Icons.thumb_down_outlined,
                                selectedIcon: Icons.thumb_down,
                                selected:
                                    message.feedback == MessageFeedback.negative,
                                tooltip: 'Kurang membantu',
                                onTap: () =>
                                    onFeedback!(MessageFeedback.negative),
                              ),
                            ],
                            if (isError && onRetry != null) ...[
                              TextButton.icon(
                                onPressed: onRetry,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Coba lagi'),
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Text(
                              time,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: timeColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 10),
              if (isUser) _UserAvatar(colorScheme: colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Salin teks'),
              onTap: () => Navigator.pop(context, 'copy'),
            ),
          ],
        ),
      ),
    );

    if (action == 'copy' && message.text.trim().isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: message.text));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teks disalin.')),
        );
      }
    }
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      onPressed: onTap,
      icon: Icon(
        selected ? selectedIcon : icon,
        size: 18,
        color: selected ? cs.primary : cs.onSurfaceVariant,
      ),
    );
  }
}

class _SourcesSection extends StatelessWidget {
  const _SourcesSection({required this.sources});

  final List<ChatSource> sources;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shown = sources.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source_outlined, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'Sumber',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final s in shown) ...[
            _SourceTile(source: s),
            if (s != shown.last) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final ChatSource source;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = source.url?.trim();
    final hasUrl = url != null && url.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: hasUrl ? () => _openUrl(context, url) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (source.excerpt.trim().isNotEmpty)
                    Text(
                      source.excerpt,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.3,
                          ),
                    ),
                ],
              ),
            ),
            if (hasUrl)
              Icon(Icons.open_in_new_rounded, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan.')),
      );
    }
  }
}

class _AttachmentsGrid extends StatelessWidget {
  const _AttachmentsGrid({required this.attachments});

  final List<ChatAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items =
        attachments.where((a) => a.type == ChatAttachmentType.image).take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in items)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 168,
              height: 112,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.55)),
              ),
              child: _AttachmentImage(dataUrl: a.dataUrl),
            ),
          ),
      ],
    );
  }
}

class _AttachmentImage extends StatelessWidget {
  const _AttachmentImage({required this.dataUrl});

  final String dataUrl;

  @override
  Widget build(BuildContext context) {
    if (dataUrl.startsWith('http://') || dataUrl.startsWith('https://')) {
      return Image.network(
        dataUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_outlined),
        ),
      );
    }
    final bytes = _tryDecodeDataUrl(dataUrl);
    if (bytes == null) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
    return Image.memory(bytes, fit: BoxFit.cover);
  }

  Uint8List? _tryDecodeDataUrl(String s) {
    final idx = s.indexOf('base64,');
    if (idx < 0) return null;
    final payload = s.substring(idx + 'base64,'.length);
    try {
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }
}

class _RoutesSection extends StatelessWidget {
  const _RoutesSection({required this.routes});

  final List<ChatRoute> routes;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rute & peta',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        for (final r in routes.take(3)) ...[
          Material(
            color: cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openMaps(context, r.mapsUrl),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.directions_walk_rounded, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${r.fromLabel} → ${r.toLabel}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                          ),
                          if (r.summary.trim().isNotEmpty)
                            Text(
                              r.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 18, color: cs.primary),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Future<void> _openMaps(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka peta.')),
      );
    }
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.colorScheme, this.isError = false});

  final ColorScheme colorScheme;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isError
            ? colorScheme.error.withValues(alpha: 0.14)
            : colorScheme.primary.withValues(alpha: 0.16),
        border: Border.all(
          color: isError
              ? colorScheme.error.withValues(alpha: 0.28)
              : colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Icon(
        isError ? Icons.cloud_off_outlined : Icons.auto_awesome_outlined,
        size: 16,
        color: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Icon(
        Icons.person,
        size: 16,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
