import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);
    final timeColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
    final hasSources = !isUser && message.sources.isNotEmpty;
    final hasAttachments = message.attachments.isNotEmpty;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) _BotAvatar(colorScheme: colorScheme),
            if (!isUser) const SizedBox(width: 10),
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? colorScheme.primary.withValues(alpha: 0.16)
                      : Theme.of(context).cardTheme.color ??
                          colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 8),
                    bottomRight: Radius.circular(isUser ? 8 : 18),
                  ),
                  border: Border.all(
                    color: isUser
                        ? colorScheme.primary.withValues(alpha: 0.18)
                        : colorScheme.outlineVariant.withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasAttachments) ...[
                      _AttachmentsGrid(attachments: message.attachments),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.32,
                          ),
                    ),
                    if (hasSources) ...[
                      const SizedBox(height: 10),
                      _SourcesCard(sources: message.sources),
                    ],
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: timeColor,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 10),
            if (isUser) _UserAvatar(colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

class _AttachmentsGrid extends StatelessWidget {
  const _AttachmentsGrid({required this.attachments});

  final List<ChatAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = attachments.where((a) => a.type == ChatAttachmentType.image).take(4).toList();
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

class _BotAvatar extends StatelessWidget {
  const _BotAvatar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary.withValues(alpha: 0.16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Icon(
        Icons.auto_awesome_outlined,
        size: 16,
        color: colorScheme.primary,
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

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.sources});

  final List<ChatSource> sources;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = sources.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sources',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final s in items) ...[
            _SourceRow(source: s),
            if (s != items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});

  final ChatSource source;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = (source.url ?? '').trim();
    final canOpen = url.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: canOpen ? () => _openUrl(context, url) : null,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                canOpen ? Icons.public : Icons.description_outlined,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    source.excerpt,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (canOpen) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.open_in_new, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Buka sumber',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka link sumber.')),
      );
    }
  }
}
