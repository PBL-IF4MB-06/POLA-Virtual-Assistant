import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'knowledge_base.dart';

/// Jawaban via [Google AI Gemini](https://ai.google.dev/) memakai API key dari pengaturan.
class GeminiService {
  GeminiService({this.modelName = 'moonshotai/Kimi-K2-Instruct-0905'});

  /// Model id di Hugging Face Router (OpenAI-compatible API).
  final String modelName;

  static const _system = '''
Kamu adalah POLA (Polibatam Assistant), asisten resmi untuk Politeknik Negeri Batam.
Aturan:
- Jawab dalam Bahasa Indonesia yang jelas dan sopan.
- Fokus pada Polibatam: akademik, jurusan, beasiswa, laboratorium, magang, layanan kampus, dan kehidupan kampus terkait Polibatam.
- Jika pertanyaan jelas di luar konteks Polibatam dan tidak ada informasi relevan di potongan basis pengetahuan, tolak singkat dan arahkan pengguna menanyakan hal terkait Polibatam.
- Jika ada potongan "basis pengetahuan internal" di bawah ini, utamakan fakta dari sana; jangan mengada-adakan detail spesifik kampus yang tidak didukung potongan tersebut atau pengetahuan umum yang wajar.
- Hindari klaim legal/medis yang tidak perlu; tetap informatif untuk mahasiswa/kalangan kampus.
''';

  /// Mengembalikan teks jawaban, atau `null` jika gagal / kosong.
  Future<String?> answerWithKbContext({
    required String apiKey,
    required String userQuestion,
    List<KnowledgeSnippet> knowledgeHits = const [],
  }) async {
    final key = apiKey.trim();
    if (key.isEmpty) return null;

    final prompt = _buildPrompt(userQuestion, knowledgeHits);
    try {
      return await _callHfRouter(token: key, model: modelName, prompt: prompt);
    } catch (_) {
      return null;
    }
  }

  /// Memanggil backend POLA (`server/`). [hint] berisi pesan singkat jika gagal (untuk ditampilkan ke pengguna).
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
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    };
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
          .post(uri, headers: headers, body: body)
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
        if (map is Map && map['error'] is String)
          apiMsg = map['error'] as String;
      } catch (_) {}
      apiMsg ??= resp.reasonPhrase ?? 'HTTP ${resp.statusCode}';
      return (reply: null, hint: _backendFailureHint(resp.statusCode, apiMsg));
    } catch (e, _) {
      final isTimeout = e is TimeoutException;
      return (
        reply: null,
        hint: isTimeout
            ? 'Backend tidak menjawab dalam 55 detik (timeout). Periksa server, jaringan, atau beban API Hugging Face.'
            : 'Tidak terhubung ke backend. Pastikan server jalan (cd server lalu npm start), '
                  'HF_TOKEN di server/.env valid, dan URL benar (Chrome/Windows: http://127.0.0.1:8787; '
                  'emulator Android: http://10.0.2.2:8787).',
      );
    }
  }

  static String _backendFailureHint(int code, String apiMessage) {
    if (code == 503) {
      return 'Server: $apiMessage — setelah mengubah .env, jalankan ulang npm start.';
    }
    if (code == 400) return 'Permintaan ditolak: $apiMessage';
    return 'Backend error ($code): $apiMessage';
  }

  String _buildPrompt(
    String userQuestion,
    List<KnowledgeSnippet> knowledgeHits,
  ) {
    final b = StringBuffer();
    if (knowledgeHits.isNotEmpty) {
      b.writeln(
        'Potongan basis pengetahuan internal (prioritaskan jika relevan):',
      );
      for (var i = 0; i < knowledgeHits.length; i++) {
        final h = knowledgeHits[i];
        b.writeln();
        b.writeln('--- ${i + 1}. ${h.sourceTitle} ---');
        b.writeln(h.text.trim());
      }
      b.writeln();
    }
    b.writeln('Pertanyaan pengguna:');
    b.writeln(userQuestion.trim());
    return b.toString();
  }

  Future<String> _callHfRouter({
    required String token,
    required String model,
    required String prompt,
  }) async {
    const uri = 'https://router.huggingface.co/v1/chat/completions';
    final resp = await http
        .post(
          Uri.parse(uri),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': _system.trim()},
              {'role': 'user', 'content': prompt},
            ],
          }),
        )
        .timeout(const Duration(seconds: 55));
    final map = jsonDecode(resp.body);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final err = (map is Map<String, dynamic> && map['error'] != null)
          ? map['error'].toString()
          : 'HTTP ${resp.statusCode}';
      throw Exception('Hugging Face error: $err');
    }
    if (map is! Map<String, dynamic>) {
      throw Exception('Respons Hugging Face tidak valid.');
    }
    final choices = map['choices'];
    if (choices is! List || choices.isEmpty) {
      throw Exception('Tidak ada choices dari Hugging Face.');
    }
    final msg = (choices.first as Map<String, dynamic>)['message'];
    if (msg is! Map<String, dynamic>) {
      throw Exception('Field message tidak valid.');
    }
    final content = msg['content'];
    if (content is String && content.trim().isNotEmpty) {
      return content.trim();
    }
    if (content is List) {
      final text = content
          .whereType<Map>()
          .map((p) => p['text'])
          .whereType<String>()
          .join()
          .trim();
      if (text.isNotEmpty) return text;
    }
    throw Exception('Model tidak mengembalikan teks.');
  }
}
