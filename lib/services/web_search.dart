import 'dart:convert';

import 'package:http/http.dart' as http;

class WebSearchResult {
  const WebSearchResult({
    required this.title,
    required this.snippet,
    required this.url,
    required this.source,
  });

  final String title;
  final String snippet;
  final String url;
  final String source;
}

class WebSearchService {
  const WebSearchService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<List<WebSearchResult>> search(String query, {int limit = 4}) async {
    final results = <WebSearchResult>[];

    // 1) Wikipedia summary (bahasa Indonesia dulu, fallback ke en)
    final wiki = await _wikiSummary(query);
    if (wiki != null) results.add(wiki);

    // 2) DuckDuckGo Instant Answer (tanpa API key; hasil terbatas tapi cukup untuk fallback)
    final ddg = await _ddgInstantAnswer(query);
    if (ddg != null) results.addAll(ddg);

    // Dedup by url
    final seen = <String>{};
    final out = <WebSearchResult>[];
    for (final r in results) {
      if (r.url.isEmpty) continue;
      if (seen.add(r.url)) out.add(r);
      if (out.length >= limit) break;
    }
    return out;
  }

  Future<WebSearchResult?> _wikiSummary(String query) async {
    final q = Uri.encodeComponent(query);
    final client = _client ?? http.Client();

    Future<WebSearchResult?> fetch(String lang) async {
      final uri = Uri.parse('https://$lang.wikipedia.org/api/rest_v1/page/summary/$q');
      final resp = await client.get(
        uri,
        headers: const {'accept': 'application/json'},
      );
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final title = (json['title'] as String?)?.trim();
      final extract = (json['extract'] as String?)?.trim();
      final contentUrls = json['content_urls'] as Map<String, dynamic>?;
      final desktop = contentUrls?['desktop'] as Map<String, dynamic>?;
      final url = (desktop?['page'] as String?)?.trim();
      if (title == null || title.isEmpty || extract == null || extract.isEmpty) {
        return null;
      }
      if (url == null || url.isEmpty) return null;
      return WebSearchResult(
        title: title,
        snippet: extract,
        url: url,
        source: 'Wikipedia',
      );
    }

    final id = await fetch('id');
    if (id != null) return id;
    return fetch('en');
  }

  Future<List<WebSearchResult>?> _ddgInstantAnswer(String query) async {
    final q = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://api.duckduckgo.com/?q=$q&format=json&no_html=1&skip_disambig=1',
    );
    final client = _client ?? http.Client();
    final resp = await client.get(uri, headers: const {'accept': 'application/json'});
    if (resp.statusCode != 200) return null;

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    final out = <WebSearchResult>[];

    final abstractText = (json['AbstractText'] as String?)?.trim() ?? '';
    final abstractUrl = (json['AbstractURL'] as String?)?.trim() ?? '';
    final heading = (json['Heading'] as String?)?.trim() ?? '';
    if (abstractText.isNotEmpty && abstractUrl.isNotEmpty) {
      out.add(
        WebSearchResult(
          title: heading.isNotEmpty ? heading : 'Ringkasan',
          snippet: abstractText,
          url: abstractUrl,
          source: 'DuckDuckGo',
        ),
      );
    }

    final related = json['RelatedTopics'];
    if (related is List) {
      for (final item in related) {
        final r = _parseRelated(item);
        if (r != null) out.add(r);
        if (out.length >= 4) break;
      }
    }

    return out;
  }

  WebSearchResult? _parseRelated(dynamic item) {
    if (item is Map<String, dynamic>) {
      // Sometimes DDG nests topics under "Topics"
      final topics = item['Topics'];
      if (topics is List && topics.isNotEmpty) {
        for (final t in topics) {
          final parsed = _parseRelated(t);
          if (parsed != null) return parsed;
        }
      }

      final text = (item['Text'] as String?)?.trim() ?? '';
      final firstUrl = (item['FirstURL'] as String?)?.trim() ?? '';
      if (text.isEmpty || firstUrl.isEmpty) return null;
      final title = text.split(' - ').first.trim();
      final snippet = text.contains(' - ')
          ? text.substring(text.indexOf(' - ') + 3).trim()
          : text;
      return WebSearchResult(
        title: title.isNotEmpty ? title : 'Hasil terkait',
        snippet: snippet,
        url: firstUrl,
        source: 'DuckDuckGo',
      );
    }
    return null;
  }
}

