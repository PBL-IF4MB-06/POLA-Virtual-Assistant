import 'dart:convert';

import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../models/chat_message.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_feature_header.dart';
import '../widgets/chat_quick_prompts.dart';
import '../widgets/chat_suggestion_chips.dart';
import '../widgets/chat_typing_indicator.dart';
import '../services/speech_input_service.dart';
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

  Future<void> _sendMessage(String text) async {
    final chat = AppStateScope.of(context).chat;
    await chat.sendUserMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = AppStateScope.of(context).chat;
    final settings = AppStateScope.of(context).settings;
    final speechLocaleId = SpeechInputService.localeFromAppLanguage(
      settings.appLanguage,
    );

    final bookmarks = AppStateScope.of(context).bookmarks;

    return AnimatedBuilder(
      animation: Listenable.merge([chat, bookmarks, settings]),
      builder: (context, _) {
        final messages = chat.activeConversation.messages;
        final suggestions = chat.followUpSuggestions;
        final isTyping = chat.isBotTyping;
        final convoTitle = chat.activeConversation.title;

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
                          if (widget.showFeatureHeader && messages.isEmpty) ...[
                            const ChatFeatureHeader(),
                            ChatQuickPrompts(
                              onSelect: (prompt) => _sendMessage(prompt),
                            ),
                          ],
                          if (messages.isEmpty && !widget.showFeatureHeader)
                            Padding(
                              padding: const EdgeInsets.only(top: 24),
                              child: Text(
                                widget.emptyHint ??
                                    'Tanya seputar Polibatam. POLA memakai sumber lokal kampus; untuk web, sertakan "Polibatam" di pertanyaan.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          for (final msg in messages)
                            TweenAnimationBuilder<double>(
                              key: ValueKey(msg.id),
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 8),
                                  child: child,
                                ),
                              ),
                              child: ChatBubble(
                                message: msg,
                                onFeedback: msg.sender == Sender.bot && !msg.isError
                                    ? (f) {
                                        chat.setMessageFeedback(msg.id, f);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              f == MessageFeedback.positive
                                                  ? 'Terima kasih atas masukan Anda.'
                                                  : 'Masukan dicatat. Kami akan perbaiki.',
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : null,
                                onRetry: msg.isError ? chat.retryLastFailedResponse : null,
                                isBookmarked: bookmarks.isBookmarked(msg.id),
                                onBookmark: msg.sender == Sender.bot &&
                                        !msg.isError &&
                                        msg.text.trim().isNotEmpty
                                    ? () async {
                                        final wasBookmarked =
                                            bookmarks.isBookmarked(msg.id);
                                        await bookmarks.toggle(
                                          messageId: msg.id,
                                          conversationTitle: convoTitle,
                                          text: msg.text,
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              wasBookmarked
                                                  ? 'Bookmark dihapus.'
                                                  : 'Jawaban disimpan ke bookmark.',
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : null,
                                onRegenerate: msg.sender == Sender.bot && !msg.isError
                                    ? () async {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Membuat ulang jawaban…'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        await chat.regenerateBotResponse(msg.id);
                                      }
                                    : null,
                              ),
                            ),
                          if (isTyping)
                            ChatTypingIndicator(
                              onCancel: chat.cancelBotResponse,
                            ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                  if (suggestions.isNotEmpty && !isTyping)
                    ChatSuggestionChips(
                      suggestions: suggestions,
                      onSelect: _sendMessage,
                    ),
                  ChatInputBar(
                    hintText: 'Tulis pertanyaan ke chatbot POLA…',
                    speechLocaleId: speechLocaleId,
                    spellCheckEnabled: settings.spellCorrection,
                    enabled: !isTyping,
                    onSend: (text) async {
                      await _sendMessage(text);
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
                      final chat = AppStateScope.of(context).chat;
                      await chat.sendUserMessage('', attachments: atts);
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              bottom: suggestions.isNotEmpty && !isTyping ? 130 : 78,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 140),
                scale: _showScrollToBottom ? 1 : 0.92,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 140),
                  opacity: _showScrollToBottom ? 1 : 0,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Gulir ke bawah',
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
