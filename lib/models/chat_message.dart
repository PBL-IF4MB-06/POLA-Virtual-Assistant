enum Sender { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final Sender sender;
  final String text;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'sender': sender.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, Object?> json) {
    final senderName = json['sender'] as String? ?? 'bot';
    final sender = Sender.values.firstWhere(
      (s) => s.name == senderName,
      orElse: () => Sender.bot,
    );

    return ChatMessage(
      id: json['id'] as String? ?? '',
      sender: sender,
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
