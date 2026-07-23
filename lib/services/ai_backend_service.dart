import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/bot_reply.dart';
import 'knowledge_base.dart';

class AiBackendResult {
  const AiBackendResult({
    this.reply,
    this.hint,
    this.images = const [],
    this.routes = const [],
  });

  final String? reply;
  final String? hint;
  final List<BotImage> images;
  final List<BotRoute> routes;
}

class AiBackendService {
  const AiBackendService();

  Future<AiBackendResult> answerWithKbContextViaBackend({
    required String backendBaseUrl,
    required String userQuestion,
    List<KnowledgeSnippet> knowledgeHits = const [],
    List<({String role, String content})> conversationHistory = const [],
  }) async {
    var root = backendBaseUrl.trim();
    if (root.isEmpty) return const AiBackendResult();
    if (!root.startsWith('http://') && !root.startsWith('https://')) {
      root = 'https://$root';
    }
    root = root.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$root/v1/chat');

    final body = jsonEncode({
      'message': userQuestion.trim(),
      'knowledgeSnippets': knowledgeHits
          .map(
            (h) => <String, String>{
              'sourceTitle': h.sourceTitle,
              'text': h.text,
            },
          )
          .toList(),
      'conversationHistory': conversationHistory
          .map(
            (t) => <String, String>{
              'role': t.role,
              'content': t.content,
            },
          )
          .toList(),
    });

    try {
      final resp = await http
          .post(
            uri,
            headers: const <String, String>{
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 55));

      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body);
        if (map is! Map<String, dynamic>) {
          return const AiBackendResult(
            hint: 'Jawaban backend tidak dikenali (bukan JSON).',
          );
        }
        final reply = map['reply'];
        if (reply is! String) {
          return const AiBackendResult(
            hint: 'Backend tidak mengirim field "reply".',
          );
        }
        final t = reply.trim();
        if (t.isEmpty) {
          return const AiBackendResult(
            hint: 'Backend mengirim jawaban kosong.',
          );
        }
        return AiBackendResult(
          reply: t,
          images: _parseImages(map['images']),
          routes: _parseRoutes(map['routes']),
        );
      }

      String? apiMsg;
      try {
        final map = jsonDecode(resp.body);
        if (map is Map && map['error'] is String) {
          apiMsg = map['error'] as String;
        }
      } catch (_) {}
      apiMsg ??= resp.reasonPhrase ?? 'HTTP ${resp.statusCode}';
      return AiBackendResult(
        hint: 'Backend error (${resp.statusCode}): $apiMsg',
      );
    } catch (e) {
      final isTimeout = e is TimeoutException;
      return AiBackendResult(
        hint: isTimeout
            ? 'Backend tidak menjawab dalam 55 detik (timeout).'
            : 'Tidak terhubung ke backend. Pastikan server jalan (cd server lalu npm start).',
      );
    }
  }

  static List<BotImage> _parseImages(Object? raw) {
    if (raw is! List) return const [];
    final out = <BotImage>[];
    for (final item in raw) {
      if (item is String && item.trim().isNotEmpty) {
        out.add(BotImage(url: item.trim()));
      } else if (item is Map) {
        final url = '${item['url'] ?? ''}'.trim();
        if (url.isEmpty) continue;
        out.add(BotImage(url: url, label: '${item['label'] ?? ''}'.trim()));
      }
    }
    return out;
  }

  static List<BotRoute> _parseRoutes(Object? raw) {
    if (raw is! List) return const [];
    final out = <BotRoute>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final mapsUrl = '${item['mapsUrl'] ?? item['url'] ?? ''}'.trim();
      if (mapsUrl.isEmpty) continue;
      out.add(
        BotRoute(
          title: '${item['title'] ?? 'Rute'}'.trim(),
          fromLabel: '${item['fromLabel'] ?? item['from'] ?? ''}'.trim(),
          toLabel: '${item['toLabel'] ?? item['to'] ?? ''}'.trim(),
          mapsUrl: mapsUrl,
          summary: '${item['summary'] ?? ''}'.trim(),
        ),
      );
    }
    return out;
  }
}
