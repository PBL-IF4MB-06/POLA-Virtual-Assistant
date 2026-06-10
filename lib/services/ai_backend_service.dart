import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'knowledge_base.dart';

class AiBackendService {
  const AiBackendService();

  Future<({String? reply, String? hint})> answerWithKbContextViaBackend({
    required String backendBaseUrl,
    required String userQuestion,
    List<KnowledgeSnippet> knowledgeHits = const [],
  }) async {
    var root = backendBaseUrl.trim();
    if (root.isEmpty) return (reply: null, hint: null);
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
          return (
            reply: null,
            hint: 'Jawaban backend tidak dikenali (bukan JSON).',
          );
        }
        final reply = map['reply'];
        if (reply is! String) {
          return (reply: null, hint: 'Backend tidak mengirim field "reply".');
        }
        final t = reply.trim();
        if (t.isEmpty) {
          return (reply: null, hint: 'Backend mengirim jawaban kosong.');
        }
        return (reply: t, hint: null);
      }

      String? apiMsg;
      try {
        final map = jsonDecode(resp.body);
        if (map is Map && map['error'] is String) {
          apiMsg = map['error'] as String;
        }
      } catch (_) {}
      apiMsg ??= resp.reasonPhrase ?? 'HTTP ${resp.statusCode}';
      return (reply: null, hint: 'Backend error (${resp.statusCode}): $apiMsg');
    } catch (e) {
      final isTimeout = e is TimeoutException;
      return (
        reply: null,
        hint: isTimeout
            ? 'Backend tidak menjawab dalam 55 detik (timeout).'
            : 'Tidak terhubung ke backend. Pastikan server jalan (cd server lalu npm start).',
      );
    }
  }
}
