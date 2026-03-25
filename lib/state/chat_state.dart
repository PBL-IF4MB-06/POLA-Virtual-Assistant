import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/chat_storage.dart';
import '../services/pola_bot.dart';

class ChatState extends ChangeNotifier {
  ChatState({PolaBot? bot, ChatStorage? storage})
      : _bot = bot ?? const PolaBot(),
        _storage = storage ?? const ChatStorage() {
    _conversations.add(_newConversation(seedWelcome: true));
    _activeConversationId = _conversations.first.id;
  }

  final PolaBot _bot;
  final ChatStorage _storage;
  final List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isBotTyping = false;

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  bool get isBotTyping => _isBotTyping;

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
    final convo = _newConversation(seedWelcome: true);
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
      ..add(_newConversation(seedWelcome: true));
    _activeConversationId = _conversations.first.id;
    _isBotTyping = false;
    notifyListeners();
    unawaited(_save());
  }

  Future<void> sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final convo = activeConversation;
    convo.messages.add(
      ChatMessage(
        id: _id(),
        sender: Sender.user,
        text: trimmed,
        createdAt: DateTime.now(),
      ),
    );

    // Update title lazily based on first user message
    if (convo.title == 'New chat') {
      convo.title = _titleFrom(trimmed);
    }

    _isBotTyping = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    convo.messages.add(
      ChatMessage(
        id: _id(),
        sender: Sender.bot,
        text: _bot.getResponse(trimmed),
        createdAt: DateTime.now(),
      ),
    );

    _isBotTyping = false;
    notifyListeners();
    unawaited(_save());
  }

  Conversation _newConversation({required bool seedWelcome}) {
    final convo = Conversation(id: _id(), title: 'New chat');
    if (seedWelcome) {
      convo.messages.add(
        ChatMessage(
          id: _id(),
          sender: Sender.bot,
          text:
              'Halo, saya POLA – asisten virtual Polibatam. Silakan tanyakan seputar jadwal, biaya, pendaftaran, atau kontak kampus.',
          createdAt: DateTime.now(),
        ),
      );
    }
    return convo;
  }

  String _titleFrom(String message) {
    final cleaned = message.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.length <= 24) return cleaned;
    return '${cleaned.substring(0, 24)}…';
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> _save() => _storage.save(_conversations, _activeConversationId);
}
