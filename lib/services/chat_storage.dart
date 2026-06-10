import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';
import 'supabase/supabase_chat_repository.dart';
import 'supabase/supabase_service.dart';

class ChatStorage {
  const ChatStorage();

  static const _conversationsKey = 'pola_conversations_v7';
  static const _activeConversationIdKey = 'pola_active_conversation_id_v7';

  bool get _useSupabase =>
      SupabaseService.isReady && SupabaseService.client.auth.currentUser != null;

  Future<void> save(List<Conversation> conversations, String? activeId) async {
    if (_useSupabase) {
      try {
        await const SupabaseChatRepository().saveAll(conversations, activeId);
        return;
      } catch (e, st) {
        debugPrint('ChatStorage Supabase save gagal, fallback lokal: $e\n$st');
      }
    }

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
    if (_useSupabase) {
      try {
        final remote = await const SupabaseChatRepository().loadAll();
        if (remote.$1.isNotEmpty) return remote;
      } catch (e, st) {
        debugPrint('ChatStorage Supabase load gagal, fallback lokal: $e\n$st');
      }
    }

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
      return (<Conversation>[], null);
    }
  }

  /// ID percakapan/pesan — UUID saat Supabase aktif.
  static String newId() {
    if (SupabaseService.isReady) {
      return SupabaseChatRepository.newId();
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
