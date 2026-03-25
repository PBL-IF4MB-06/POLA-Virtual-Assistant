import 'package:flutter/material.dart';

import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(message.createdAt).format(context);
    final timeColor = colorScheme.onSurfaceVariant.withOpacity(0.75);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUser ? colorScheme.primaryContainer : colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: timeColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
