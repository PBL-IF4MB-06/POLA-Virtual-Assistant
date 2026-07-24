import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/chat_message.dart';
import '../models/bot_reply.dart';
import '../models/conversation.dart';
import '../config/ai_backend.dart';
import '../services/chat_storage.dart';
import '../services/pola_bot.dart';
import '../services/suggestion_engine.dart';
import 'settings_state.dart';

typedef ConversationTurn = ({String role, String content});

class ChatState extends ChangeNotifier {
  ChatState({
    required SettingsState settings,
    PolaBot? bot,
    ChatStorage? storage,
  })  : _settings = settings,
        _bot = bot ?? PolaBot(),
        _storage = storage ?? const ChatStorage() {
    _conversations.add(_newConversation());
    _activeConversationId = _conversations.first.id;
  }

  static const _maxBackendRetries = 3;

  final SettingsState _settings;
  final PolaBot _bot;
  final ChatStorage _storage;
  final SuggestionEngine _suggestions = const SuggestionEngine();
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isBotTyping = false;
  List<String> _followUpSuggestions = const [];
  int _requestGeneration = 0;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isBotTyping => _isBotTyping;
  List<String> get followUpSuggestions => List.unmodifiable(_followUpSuggestions);

  Conversation get activeConversation =>
      _conversations.firstWhere((c) => c.id == _activeConversationId);

  String? get activeLastMessageId => activeConversation.lastMessage?.id;

  int get totalChatCount => _conversations.length;

  int get questionsToday {
    final now = DateTime.now();
    var count = 0;
    for (final c in _conversations) {
      for (final m in c.messages) {
        if (m.sender == Sender.user &&
            m.createdAt.year == now.year &&
            m.createdAt.month == now.month &&
            m.createdAt.day == now.day) {
          count++;
        }
      }
    }
    return count;
  }

  Future<void> loadFromStorage() async {
    final (loaded, activeId) = await _storage.load();
    if (loaded.isEmpty) return;

    _conversations
      ..clear()
      ..addAll(loaded);
    _activeConversationId = activeId ?? _conversations.first.id;
    notifyListeners();
  }

  void startNewConversation() {
    final convo = _newConversation();
    _conversations.insert(0, convo);
    _activeConversationId = convo.id;
    _followUpSuggestions = const [];
    notifyListeners();
    unawaited(_save());
  }

  void setActiveConversation(String id) {
    if (_activeConversationId == id) return;
    _activeConversationId = id;
    _followUpSuggestions = const [];
    notifyListeners();
    unawaited(_save());
  }

  void deleteConversation(String id) {
    if (_conversations.length <= 1) return;
    _conversations.removeWhere((c) => c.id == id);
    if (_activeConversationId == id) {
      _activeConversationId = _conversations.first.id;
    }
    notifyListeners();
    unawaited(_save());
  }

  void renameConversation(String id, String newTitle) {
    final title = newTitle.trim();
    if (title.isEmpty) return;
    final convo = _conversations.firstWhere((c) => c.id == id);
    convo.title = title;
    notifyListeners();
    unawaited(_save());
  }

  void clearAllConversations() {
    _conversations
      ..clear()
      ..add(_newConversation());
    _activeConversationId = _conversations.first.id;
    _isBotTyping = false;
    _followUpSuggestions = const [];
    notifyListeners();
    unawaited(_save());
  }

  void cancelBotResponse() {
    if (!_isBotTyping) return;
    _requestGeneration++;
    _isBotTyping = false;
    notifyListeners();
  }

  void setMessageFeedback(String messageId, MessageFeedback feedback) {
    final convo = activeConversation;
    final idx = convo.messages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    final msg = convo.messages[idx];
    if (msg.sender != Sender.bot || msg.isError) return;

    final next = msg.feedback == feedback
        ? msg.copyWith(clearFeedback: true)
        : msg.copyWith(feedback: feedback);
    convo.messages[idx] = next;
    notifyListeners();
    unawaited(_save());
  }

  Future<void> regenerateBotResponse(String botMessageId) async {
    if (_isBotTyping) return;
    final convo = activeConversation;
    final botIdx = convo.messages.indexWhere((m) => m.id == botMessageId);
    if (botIdx < 0) return;
    if (convo.messages[botIdx].sender != Sender.bot ||
        convo.messages[botIdx].isError) {
      return;
    }

    ChatMessage? userMsg;
    for (var i = botIdx - 1; i >= 0; i--) {
      if (convo.messages[i].sender == Sender.user) {
        userMsg = convo.messages[i];
        break;
      }
    }
    if (userMsg == null) return;

    convo.messages.removeAt(botIdx);
    notifyListeners();

    final prompt = _buildBotPrompt(userMsg.text, userMsg.attachments);
    await _respondToUser(
      convo,
      prompt,
      userMsg.attachments,
      userPromptForSuggestions: userMsg.text,
    );
  }

  Future<void> retryLastFailedResponse() async {
    final convo = activeConversation;
    if (convo.messages.isEmpty || _isBotTyping) return;

    while (convo.messages.isNotEmpty &&
        convo.messages.last.sender == Sender.bot &&
        convo.messages.last.isError) {
      convo.messages.removeLast();
    }

    if (convo.messages.isEmpty) return;
    final lastUser = convo.messages.last;
    if (lastUser.sender != Sender.user) return;

    notifyListeners();

    final prompt = _buildBotPrompt(lastUser.text, lastUser.attachments);
    await _respondToUser(
      convo,
      prompt,
      lastUser.attachments,
      userPromptForSuggestions: lastUser.text,
    );
  }

  Future<void> sendUserMessage(
    String text, {
    List<ChatAttachment> attachments = const <ChatAttachment>[],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;
    if (_isBotTyping) return;

    if (_settings.hapticFeedback) {
      unawaited(HapticFeedback.lightImpact());
    }

    final convo = activeConversation;
    convo.messages.add(
      ChatMessage(
        id: _id(),
        sender: Sender.user,
        text: trimmed,
        attachments: attachments,
        createdAt: DateTime.now(),
      ),
    );

    if (convo.title == 'New chat') {
      convo.title = trimmed.isNotEmpty ? _titleFrom(trimmed) : 'Lampiran';
    }

    _followUpSuggestions = const [];
    notifyListeners();

    final promptForBot = _buildBotPrompt(trimmed, attachments);
    await _respondToUser(
      convo,
      promptForBot,
      attachments,
      userPromptForSuggestions: trimmed.isNotEmpty ? trimmed : promptForBot,
    );
  }

  Future<void> _respondToUser(
    Conversation convo,
    String promptForBot,
    List<ChatAttachment> attachments, {
    required String userPromptForSuggestions,
  }) async {
    final generation = ++_requestGeneration;
    _isBotTyping = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (generation != _requestGeneration) return;

    final history = _buildConversationHistory(convo);
    final backendUrl = aiBackendBaseUrl();

    BotReply? reply;
    String? lastError;

    if (backendUrl.trim().isNotEmpty) {
      var delayMs = 900;
      for (var attempt = 0; attempt < _maxBackendRetries; attempt++) {
        if (generation != _requestGeneration) return;
        try {
          reply = await _bot.getResponse(
            promptForBot,
            conversationHistory: history,
            webSearchEnabled: _settings.webSearchEnabled,
            googleApiKey: _settings.googleCseApiKey,
            googleCx: _settings.googleCseCx,
            aiBackendBaseUrl: backendUrl,
          );
          break;
        } catch (e) {
          lastError = e.toString().replaceFirst('Exception: ', '');
          if (attempt < _maxBackendRetries - 1) {
            await Future<void>.delayed(Duration(milliseconds: delayMs));
            delayMs = (delayMs * 1.6).clamp(900, 8000).toInt();
          }
        }
      }
    } else {
      try {
        reply = await _bot.getResponse(
          promptForBot,
          conversationHistory: history,
          webSearchEnabled: _settings.webSearchEnabled,
          googleApiKey: _settings.googleCseApiKey,
          googleCx: _settings.googleCseCx,
          aiBackendBaseUrl: backendUrl,
        );
      } catch (e) {
        lastError = e.toString().replaceFirst('Exception: ', '');
      }
    }

    if (generation != _requestGeneration) return;

    if (reply == null) {
      convo.messages.add(
        ChatMessage(
          id: _id(),
          sender: Sender.bot,
          text: lastError ??
              'POLA tidak dapat menjawab saat ini. Periksa koneksi internet atau coba lagi.',
          isError: true,
          createdAt: DateTime.now(),
        ),
      );
      _isBotTyping = false;
      _followUpSuggestions = const [];
      notifyListeners();
      unawaited(_save());
      return;
    }

    convo.messages.add(
      ChatMessage(
        id: _id(),
        sender: Sender.bot,
        text: reply.text,
        createdAt: DateTime.now(),
      ),
    );

    _isBotTyping = false;
    if (_settings.followUpSuggestions) {
      _followUpSuggestions =
          _suggestions.suggestFollowUps(userPromptForSuggestions);
    } else {
      _followUpSuggestions = const [];
    }
    notifyListeners();
    unawaited(_save());
  }

  List<ConversationTurn> _buildConversationHistory(Conversation convo) {
    if (convo.messages.length <= 1) return const [];

    final prior = convo.messages.sublist(0, convo.messages.length - 1);
    const maxMessages = 10;
    final recent = prior.length > maxMessages
        ? prior.sublist(prior.length - maxMessages)
        : prior;

    return [
      for (final m in recent)
        if (m.text.trim().isNotEmpty && !m.isError)
          (
            role: m.sender == Sender.user ? 'user' : 'assistant',
            content: m.text.trim(),
          ),
    ];
  }

  String _buildBotPrompt(String userText, List<ChatAttachment> attachments) {
    if (attachments.isEmpty) return userText;
    final b = StringBuffer();
    if (userText.trim().isNotEmpty) {
      b.writeln(userText.trim());
    }
    b.writeln();
    b.writeln(
      'Konteks tambahan: pengguna mengirim lampiran (${attachments.length} item).',
    );
    b.writeln(
      'Jika pertanyaan tidak jelas dari lampiran, minta pengguna menjelaskan detail.',
    );
    return b.toString().trim();
  }

  Conversation _newConversation() {
    return Conversation(id: _id(), title: 'New chat');
  }

  String _titleFrom(String message) {
    final cleaned = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 24) return cleaned;
    return '${cleaned.substring(0, 24)}…';
  }

  String _id() => ChatStorage.newId();

  Future<void> _save() => _storage.save(_conversations, _activeConversationId);
}
