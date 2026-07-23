enum Sender { user, bot }

enum MessageFeedback { positive, negative }

enum ChatAttachmentType { image }

class ChatAttachment {
  const ChatAttachment({
    required this.type,
    required this.dataUrl,
    required this.fileName,
  });

  final ChatAttachmentType type;
  /// data:image/...;base64,... ATAU https://... untuk gambar jaringan.
  final String dataUrl;
  final String fileName;

  bool get isNetwork =>
      dataUrl.startsWith('http://') || dataUrl.startsWith('https://');

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

/// Kartu rute / navigasi di bubble bot.
class ChatRoute {
  const ChatRoute({
    required this.title,
    required this.fromLabel,
    required this.toLabel,
    required this.mapsUrl,
    this.summary = '',
  });

  final String title;
  final String fromLabel;
  final String toLabel;
  final String mapsUrl;
  final String summary;

  Map<String, Object?> toJson() => {
        'title': title,
        'fromLabel': fromLabel,
        'toLabel': toLabel,
        'mapsUrl': mapsUrl,
        'summary': summary,
      };

  factory ChatRoute.fromJson(Map<String, Object?> json) {
    return ChatRoute(
      title: json['title'] as String? ?? '',
      fromLabel: json['fromLabel'] as String? ?? '',
      toLabel: json['toLabel'] as String? ?? '',
      mapsUrl: json['mapsUrl'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
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
    this.routes = const <ChatRoute>[],
    this.feedback,
    this.isError = false,
  });

  final String id;
  final Sender sender;
  final String text;
  final DateTime createdAt;
  final List<ChatSource> sources;
  final List<ChatAttachment> attachments;
  final List<ChatRoute> routes;
  final MessageFeedback? feedback;
  final bool isError;

  ChatMessage copyWith({
    MessageFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return ChatMessage(
      id: id,
      sender: sender,
      text: text,
      createdAt: createdAt,
      sources: sources,
      attachments: attachments,
      routes: routes,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      isError: isError,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'sources': sources.map((s) => s.toJson()).toList(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'routes': routes.map((r) => r.toJson()).toList(),
        if (feedback != null) 'feedback': feedback!.name,
        if (isError) 'isError': true,
      };

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final senderName = json['sender'] as String? ?? 'bot';
    final sender = Sender.values.firstWhere(
      (s) => s.name == senderName,
      orElse: () => Sender.bot,
    );

    final rawSources = json['sources'] as List<dynamic>? ?? <dynamic>[];
    final rawAttachments = json['attachments'] as List<dynamic>? ?? <dynamic>[];
    final rawRoutes = json['routes'] as List<dynamic>? ?? <dynamic>[];

    MessageFeedback? feedback;
    final feedbackName = json['feedback'] as String?;
    if (feedbackName != null) {
      for (final f in MessageFeedback.values) {
        if (f.name == feedbackName) {
          feedback = f;
          break;
        }
      }
    }

    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: sender,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sources: rawSources
          .whereType<Map>()
          .map((e) => ChatSource.fromJson(Map<String, Object?>.from(e)))
          .where((s) => s.title.trim().isNotEmpty)
          .toList(),
      attachments: rawAttachments
          .whereType<Map>()
          .map((e) => ChatAttachment.fromJson(Map<String, Object?>.from(e)))
          .where((a) => a.dataUrl.trim().isNotEmpty)
          .toList(),
      routes: rawRoutes
          .whereType<Map>()
          .map((e) => ChatRoute.fromJson(Map<String, Object?>.from(e)))
          .where((r) => r.mapsUrl.trim().isNotEmpty)
          .toList(),
      feedback: feedback,
      isError: json['isError'] as bool? ?? false,
    );
  }
}
