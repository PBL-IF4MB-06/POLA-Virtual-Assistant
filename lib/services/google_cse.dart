import 'dart:convert';

import 'package:http/http.dart' as http;

class GoogleCseResult {
  const GoogleCseResult({
    required this.title,
    required this.snippet,
    required this.url,
    required this.displayLink,
  });

  final String title;
  final String snippet;
  final String url;
  final String displayLink;
}

class GoogleCseService {
  const GoogleCseService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<List<GoogleCseResult>> search({
    required String apiKey,
    required String cx,
    required String query,
    int limit = 5,
  }) async {
    final q = Uri.encodeQueryComponent(query);
    final uri = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$q&num=${limit.clamp(1, 10)}',
    );

    final client = _client ?? http.Client();
    final resp = await client.get(uri, headers: const {'accept': 'application/json'});
    if (resp.statusCode != 200) {
      throw GoogleCseException('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = json['items'];
    if (items is! List) return const [];

    final out = <GoogleCseResult>[];
    for (final it in items) {
      if (it is! Map<String, dynamic>) continue;
      final title = (it['title'] as String?)?.trim() ?? '';
      final snippet = (it['snippet'] as String?)?.trim() ?? '';
      final link = (it['link'] as String?)?.trim() ?? '';
      final displayLink = (it['displayLink'] as String?)?.trim() ?? '';
      if (title.isEmpty || link.isEmpty) continue;
      out.add(
        GoogleCseResult(
          title: title,
          snippet: snippet,
          url: link,
          displayLink: displayLink,
        ),
      );
      if (out.length >= limit) break;
    }
    return out;
  }

  Future<void> testConnection({
    required String apiKey,
    required String cx,
  }) async {
    // Query ringan yang stabil.
    await search(apiKey: apiKey, cx: cx, query: 'Polibatam', limit: 1);
  }
}

class GoogleCseException implements Exception {
  GoogleCseException(this.message);
  final String message;
  @override
  String toString() => 'GoogleCseException: $message';
}

