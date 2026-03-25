import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';

class ChatStorage {
  const ChatStorage();

  static const _conversationsKey = 'pola_conversations_v1';
  static const _activeConversationIdKey = 'pola_active_conversation_id_v1';

  Future<void> save(List<Conversation> conversations, String? activeId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = conversations.map((c) => c.toJson()).toList();
    await prefs.setString(_conversationsKey, jsonEncode(data));

    if (activeId != null) {
      await prefs.setString(_activeConversationIdKey, activeId);
    } else {
      await prefs.remove(_activeConversationIdKey);
    }
  }

  Future<(List<Conversation>, String?)> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_conversationsKey);
    if (raw == null) return (<Conversation>[], null);

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final conversations = decoded
          .whereType<Map<String, Object?>>()
          .map(Conversation.fromJson)
          .toList();
      final activeId = prefs.getString(_activeConversationIdKey);
      return (conversations, activeId);
    } catch (_) {
      // Jika data rusak, kembalikan kosong saja.
      return (<Conversation>[], null);
    }
  }
}

