enum Sender { user, bot }

enum ChatAttachmentType { image }

class ChatAttachment {
  const ChatAttachment({
    required this.type,
    required this.dataUrl,
    required this.fileName,
  });

  final ChatAttachmentType type;
  final String dataUrl; // e.g. data:image/jpeg;base64,...
  final String fileName;

  Map<String, Object?> toJson() => {
        'type': type.name,
        'dataUrl': dataUrl,
        'fileName': fileName,
      };

  factory ChatAttachment.fromJson(Map<String, Object?> json) {
    final t = json['type'] as String? ?? 'image';
    final type = ChatAttachmentType.values.firstWhere(
      (e) => e.name == t,
      orElse: () => ChatAttachmentType.image,
    );
    return ChatAttachment(
      type: type,
      dataUrl: json['dataUrl'] as String? ?? '',
      fileName: json['fileName'] as String? ?? '',
    );
  }
}

class ChatSource {
  const ChatSource({
    required this.title,
    required this.excerpt,
    this.url,
  });

  final String title;
  final String excerpt;
  final String? url;

  Map<String, Object?> toJson() => {
        'title': title,
        'excerpt': excerpt,
        'url': url,
      };

  factory ChatSource.fromJson(Map<String, Object?> json) {
    return ChatSource(
      title: json['title'] as String? ?? '',
      excerpt: json['excerpt'] as String? ?? '',
      url: json['url'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.sources = const <ChatSource>[],
    this.attachments = const <ChatAttachment>[],
  });

  final String id;
  final Sender sender;
  final String text;
  final DateTime createdAt;
  final List<ChatSource> sources;
  final List<ChatAttachment> attachments;

  Map<String, Object?> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'sources': sources.map((s) => s.toJson()).toList(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final senderName = json['sender'] as String? ?? 'bot';
    final sender = Sender.values.firstWhere(
      (s) => s.name == senderName,
      orElse: () => Sender.bot,
    );

    final rawSources = json['sources'] as List<dynamic>? ?? <dynamic>[];
    final rawAttachments = json['attachments'] as List<dynamic>? ?? <dynamic>[];

    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: sender,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sources: rawSources
          .whereType<Map<String, Object?>>()
          .map(ChatSource.fromJson)
          .where((s) => s.title.trim().isNotEmpty && s.excerpt.trim().isNotEmpty)
          .toList(),
      attachments: rawAttachments
          .whereType<Map<String, Object?>>()
          .map(ChatAttachment.fromJson)
          .where((a) => a.dataUrl.trim().isNotEmpty)
          .toList(),
    );
  }
}
