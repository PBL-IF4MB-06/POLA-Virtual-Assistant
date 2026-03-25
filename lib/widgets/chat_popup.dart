import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../pages/chat_page.dart';

Future<void> showChatPopup(
  BuildContext context, {
  VoidCallback? onOpened,
  VoidCallback? onClosed,
}) async {
  final mq = MediaQuery.of(context);
  final width = mq.size.width;

  if (width < 700) {
    onOpened?.call();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return _ChatPopupSurface(
              scrollController: scrollController,
              onClose: () => Navigator.of(context).pop(),
            );
          },
        );
      },
    );
    onClosed?.call();
    return;
  }

  onOpened?.call();
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    pageBuilder: (context, _, __) {
      final maxW = (mq.size.width * 0.36).clamp(360.0, 480.0);
      final maxH = (mq.size.height * 0.78).clamp(520.0, 760.0);

      return SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              elevation: 10,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxW,
                  maxHeight: maxH,
                  minWidth: 360,
                  minHeight: 520,
                ),
                child: _ChatPopupSurface(
                  scrollController: null,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 180),
  );
  onClosed?.call();
}

class _ChatPopupSurface extends StatelessWidget {
  const _ChatPopupSurface({
    required this.scrollController,
    required this.onClose,
  });

  final ScrollController? scrollController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;

    return Column(
      children: [
        AnimatedBuilder(
          animation: chat,
          builder: (context, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 6),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.school,
                      size: 18,
                      color:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.activeConversation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'POLA - Polibatam Assistant',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'New chat',
                    onPressed: chat.startNewConversation,
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: scrollController == null
              ? const ChatPage()
              : PrimaryScrollController(
                  controller: scrollController!,
                  child: const ChatPage(),
                ),
        ),
      ],
    );
  }
}

