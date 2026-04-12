class BotReply {
  const BotReply({required this.text, required this.sources});

  final String text;
  final List<BotSource> sources;
}

class BotSource {
  const BotSource({
    required this.id,
    required this.title,
    required this.excerpt,
    this.url,
  });

  final String id;
  final String title;
  final String excerpt;
  final String? url;
}

