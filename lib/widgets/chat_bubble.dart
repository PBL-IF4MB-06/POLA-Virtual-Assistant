import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import 'formatted_message_text.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);
    final timeColor = isUser
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.68)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.75);
    final hasAttachments = message.attachments.isNotEmpty;
    final bubbleColor = isUser
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final bubbleFg =
        isUser ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final bubbleBorder = isUser
        ? colorScheme.primary.withValues(alpha: 0.28)
        : colorScheme.outlineVariant.withValues(alpha: 0.28);

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
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 10),
                    bottomRight: Radius.circular(isUser ? 10 : 18),
                  ),
                  border: Border.all(
                    color: bubbleBorder,
                  ),
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
                    FormattedMessageText(
                      text: message.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: bubbleFg,
                            height: 1.32,
                          ),
                    ),
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
