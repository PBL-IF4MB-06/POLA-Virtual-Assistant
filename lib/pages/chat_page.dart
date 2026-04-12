import 'dart:convert';

import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_feature_header.dart';
import '../widgets/chat_input_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    this.showFeatureHeader = true,
    this.emptyHint,
  });

  final bool showFeatureHeader;
  final String? emptyHint;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;

    return AnimatedBuilder(
      animation: chat,
      builder: (context, _) {
        final messages = chat.activeConversation.messages;
        return Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.axis != Axis.vertical) return false;
                        if (!_scrollController.hasClients) return false;
                        final distanceFromBottom =
                            n.metrics.maxScrollExtent - n.metrics.pixels;
                        final shouldShow = distanceFromBottom > 260;
                        if (shouldShow != _showScrollToBottom) {
                          setState(() => _showScrollToBottom = shouldShow);
                        }
                        return false;
                      },
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          if (widget.showFeatureHeader && messages.isEmpty)
                            const ChatFeatureHeader(),
                          if (messages.isEmpty && !widget.showFeatureHeader)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                widget.emptyHint ??
                                    'Tanya seputar Polibatam. POLA memakai sumber lokal kampus; untuk web, sertakan "Polibatam" di pertanyaan.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          for (final msg in messages) ChatBubble(message: msg),
                          if (chat.isBotTyping)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'POLA sedang mencari sumber...',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  ChatInputBar(
                    hintText: 'Tulis pertanyaan…',
                    onSend: (text) async {
                      await chat.sendUserMessage(text);
                      _scrollToBottom();
                    },
                  onSendAttachments: (picked) async {
                    final atts = picked
                        .map(
                          (p) => ChatAttachment(
                            type: ChatAttachmentType.image,
                            fileName: p.fileName,
                            dataUrl:
                                'data:${p.mimeType};base64,${base64Encode(p.bytes)}',
                          ),
                        )
                        .toList();
                    await chat.sendUserMessage('', attachments: atts);
                    _scrollToBottom();
                  },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: 78,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 140),
                scale: _showScrollToBottom ? 1 : 0.92,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  opacity: _showScrollToBottom ? 1 : 0,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Scroll to bottom',
                    onPressed: _scrollToBottom,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
