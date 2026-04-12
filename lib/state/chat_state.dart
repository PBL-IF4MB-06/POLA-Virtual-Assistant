import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/ai_backend_dev.dart';
import '../models/chat_message.dart';
import '../models/bot_reply.dart';
import '../models/conversation.dart';
import '../services/chat_storage.dart';
import '../services/pola_bot.dart';
import '../services/suggestion_engine.dart';
import 'settings_state.dart';

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

  final SettingsState _settings;
  final PolaBot _bot;
  final ChatStorage _storage;
  final SuggestionEngine _suggestions = const SuggestionEngine();
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isBotTyping = false;
  List<String> _followUpSuggestions = const [];

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isBotTyping => _isBotTyping;
  List<String> get followUpSuggestions => List.unmodifiable(_followUpSuggestions);

  Conversation get activeConversation =>
      _conversations.firstWhere((c) => c.id == _activeConversationId);

  String? get activeLastMessageId => activeConversation.lastMessage?.id;

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
    notifyListeners();
    unawaited(_save());
  }

  void setActiveConversation(String id) {
    if (_activeConversationId == id) return;
    _activeConversationId = id;
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
    notifyListeners();
    unawaited(_save());
  }

  Future<void> sendUserMessage(
    String text, {
    List<ChatAttachment> attachments = const <ChatAttachment>[],
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;

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

    // Update title lazily based on first user message
    if (convo.title == 'New chat') {
      convo.title = trimmed.isNotEmpty ? _titleFrom(trimmed) : 'Lampiran';
    }

    _isBotTyping = true;
    _followUpSuggestions = const [];
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    final promptForBot = _buildBotPrompt(trimmed, attachments);
    BotReply reply;
    try {
      reply = await _bot.getResponse(
        promptForBot,
        webSearchEnabled: _settings.webSearchEnabled,
        googleApiKey: _settings.googleCseApiKey,
        googleCx: _settings.googleCseCx,
        aiBackendBaseUrl: aiBackendUrlOrDevDefault(_settings.aiBackendBaseUrl),
        geminiApiKey: _settings.geminiApiKey,
      );
    } catch (_) {
      reply = const BotReply(
        text:
            'Maaf, ada kendala saat mengambil jawaban dari sumber lokal. Coba lagi sebentar ya.',
        sources: [],
      );
    }

    convo.messages.add(
      ChatMessage(
        id: _id(),
        sender: Sender.bot,
        text: reply.text,
        sources: reply.sources
            .map(
              (s) => ChatSource(title: s.title, excerpt: s.excerpt, url: s.url),
            )
            .toList(),
        createdAt: DateTime.now(),
      ),
    );

    _isBotTyping = false;
    if (_settings.followUpSuggestions) {
      _followUpSuggestions = _suggestions.suggestFollowUps(trimmed.isNotEmpty ? trimmed : promptForBot);
    } else {
      _followUpSuggestions = const [];
    }
    notifyListeners();
    unawaited(_save());
  }

  String _buildBotPrompt(String userText, List<ChatAttachment> attachments) {
    if (attachments.isEmpty) return userText;
    final b = StringBuffer();
    if (userText.trim().isNotEmpty) {
      b.writeln(userText.trim());
    }
    b.writeln();
    b.writeln('Konteks tambahan: pengguna mengirim lampiran (${attachments.length} item).');
    b.writeln('Jika pertanyaan tidak jelas dari lampiran, minta pengguna menjelaskan detail.');
    return b.toString().trim();
  }

  /// Intro Polibatam ditampilkan sebagai satu bubble UI ([ChatFeatureHeader]), bukan pesan bot —
  /// supaya tidak dobel dengan bubble sambutan.
  Conversation _newConversation() {
    return Conversation(id: _id(), title: 'New chat');
  }

  String _titleFrom(String message) {
    final cleaned = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 24) return cleaned;
    return '${cleaned.substring(0, 24)}…';
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _save() => _storage.save(_conversations, _activeConversationId);
}
