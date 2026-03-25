import 'package:flutter/material.dart';

class ChatLauncherFab extends StatelessWidget {
  const ChatLauncherFab({
    super.key,
    required this.onPressed,
    this.onLongPress,
    this.hasUnread = false,
  });

  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FloatingActionButton(
            mini: true,
            tooltip: 'Buka chat POLA',
            onPressed: onPressed,
            child: const Icon(Icons.chat_bubble_rounded),
          ),
          if (hasUnread)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

