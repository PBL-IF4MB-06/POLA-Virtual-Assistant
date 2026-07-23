class BotReply {
  const BotReply({
    required this.text,
    this.sources = const [],
    this.imageUrls = const [],
    this.routes = const [],
  });

  final String text;
  final List<BotSource> sources;
  final List<BotImage> imageUrls;
  final List<BotRoute> routes;
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

class BotImage {
  const BotImage({required this.url, this.label = ''});

  final String url;
  final String label;
}

class BotRoute {
  const BotRoute({
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
}
