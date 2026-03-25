import 'chat_message.dart';

class Conversation {
  Conversation({
    required this.id,
    required this.title,
    DateTime? createdAt,
    List<ChatMessage>? messages,
  })  : createdAt = createdAt ?? DateTime.now(),
        messages = messages ?? <ChatMessage>[];

  final String id;
  String title;
  final DateTime createdAt;
  final List<ChatMessage> messages;

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory Conversation.fromJson(Map<String, Object?> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? <dynamic>[];

    return Conversation(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'New chat',
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: rawMessages
          .whereType<Map<String, Object?>>()
          .map(ChatMessage.fromJson)
          .toList(),
    );
  }
}
