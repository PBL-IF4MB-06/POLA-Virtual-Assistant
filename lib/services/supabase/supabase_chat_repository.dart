import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import 'supabase_service.dart';

const _uuid = Uuid();

class SupabaseChatRepository {
  const SupabaseChatRepository();

  SupabaseClient get _db => SupabaseService.client;

  String? get _userId => _db.auth.currentUser?.id;

  Future<(List<Conversation>, String?)> loadAll() async {
    final uid = _userId;
    if (uid == null) return (<Conversation>[], null);

    final convoRows = await _db
        .from('conversations')
        .select()
        .eq('user_id', uid)
        .order('updated_at', ascending: false);

    if (convoRows.isEmpty) return (<Conversation>[], null);

    final convoIds = convoRows.map((r) => r['id'] as String).toList();
    final msgRows = await _db
        .from('messages')
        .select()
        .inFilter('conversation_id', convoIds)
        .order('created_at', ascending: true);

    final msgsByConvo = <String, List<ChatMessage>>{};
    for (final row in msgRows) {
      final cid = row['conversation_id'] as String;
      msgsByConvo.putIfAbsent(cid, () => []).add(_messageFromRow(row));
    }

    String? activeId;
    final conversations = <Conversation>[];
    for (final row in convoRows) {
      final id = row['id'] as String;
      if (row['is_active'] == true) activeId = id;
      conversations.add(
        Conversation(
          id: id,
          title: row['title'] as String? ?? 'New chat',
          createdAt: DateTime.parse(row['created_at'] as String),
          messages: msgsByConvo[id] ?? [],
        ),
      );
    }

    activeId ??= conversations.isNotEmpty ? conversations.first.id : null;
    return (conversations, activeId);
  }

  Future<void> saveAll(
    List<Conversation> conversations,
    String? activeId,
  ) async {
    final uid = _userId;
    if (uid == null) return;

    final existingRows = await _db
        .from('conversations')
        .select('id')
        .eq('user_id', uid);
    final existingIds =
        existingRows.map((r) => r['id'] as String).toSet();
    final incomingIds = conversations.map((c) => c.id).toSet();

    // Hapus percakapan yang dihapus di client.
    for (final oldId in existingIds.difference(incomingIds)) {
      await _db.from('conversations').delete().eq('id', oldId);
    }

    for (final convo in conversations) {
      final isActive = convo.id == activeId;
      final isNew = !existingIds.contains(convo.id);

      if (isNew) {
        await _db.from('conversations').insert({
          'id': convo.id,
          'user_id': uid,
          'title': convo.title,
          'is_active': isActive,
          'created_at': convo.createdAt.toIso8601String(),
        });
      } else {
        await _db.from('conversations').update({
          'title': convo.title,
          'is_active': isActive,
        }).eq('id', convo.id);
      }

      await _syncMessages(convo);
    }

    if (activeId != null) {
      await _db.rpc('set_active_conversation', params: {'convo_id': activeId});
    }
  }

  Future<void> _syncMessages(Conversation convo) async {
    final existingRows = await _db
        .from('messages')
        .select('id')
        .eq('conversation_id', convo.id);
    final existingIds =
        existingRows.map((r) => r['id'] as String).toSet();
    final incomingIds = convo.messages.map((m) => m.id).toSet();

    for (final oldId in existingIds.difference(incomingIds)) {
      await _db.from('messages').delete().eq('id', oldId);
    }

    for (final msg in convo.messages) {
      if (existingIds.contains(msg.id)) continue;
      await _db.from('messages').insert({
        'id': _isUuid(msg.id) ? msg.id : _uuid.v4(),
        'conversation_id': convo.id,
        'sender': msg.sender.name,
        'text': msg.text,
        'sources': msg.sources.map((s) => s.toJson()).toList(),
        'attachments': msg.attachments.map((a) => a.toJson()).toList(),
        'created_at': msg.createdAt.toIso8601String(),
      });
    }
  }

  static ChatMessage _messageFromRow(Map<String, dynamic> row) {
    final rawSources = row['sources'];
    final rawAttachments = row['attachments'];

    return ChatMessage(
      id: row['id'] as String,
      sender: Sender.values.firstWhere(
        (s) => s.name == (row['sender'] as String? ?? 'bot'),
        orElse: () => Sender.bot,
      ),
      text: row['text'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
      sources: rawSources is List
          ? rawSources
              .whereType<Map>()
              .map((m) => ChatSource.fromJson(Map<String, Object?>.from(m)))
              .toList()
          : const [],
      attachments: rawAttachments is List
          ? rawAttachments
              .whereType<Map>()
              .map((m) => ChatAttachment.fromJson(Map<String, Object?>.from(m)))
              .toList()
          : const [],
    );
  }

  static bool _isUuid(String id) {
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(id);
  }

  /// ID baru yang kompatibel dengan PostgreSQL uuid.
  static String newId() => _uuid.v4();
}
