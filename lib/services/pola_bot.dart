import '../models/bot_reply.dart';
import 'answer_formatter.dart';
import 'admin_kb_store.dart';
import 'ai_backend_service.dart';
import 'knowledge_base.dart';
import 'polibatam_scope.dart';
import 'web_search.dart';
import 'google_cse.dart';

class PolaBot {
  PolaBot({
    KnowledgeBase? kb,
    WebSearchService? web,
    GoogleCseService? google,
    AdminKbStore? adminStore,
    AiBackendService? backend,
  }) : _kb = kb ?? KnowledgeBase(),
       _web = web ?? const WebSearchService(),
       _google = google ?? const GoogleCseService(),
       _adminStore = adminStore ?? const AdminKbStore(),
       _backend = backend ?? const AiBackendService();

  final KnowledgeBase _kb;
  final WebSearchService _web;
  final GoogleCseService _google;
  final AdminKbStore _adminStore;
  final AiBackendService _backend;
  final AnswerFormatter _fmt = const AnswerFormatter();

  Future<BotReply> getResponse(
    String question, {
    bool webSearchEnabled = false,
    String googleApiKey = '',
    String googleCx = '',
    String aiBackendBaseUrl = '',
  }) async {
    await _kb.ensureLoaded();
    final cleaned = question.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 1) Cuplikan KB untuk konteks AI / template (BM25).
    final hits = _kb.search(question, limit: 5);

    final backendUrl = aiBackendBaseUrl.trim();
    if (backendUrl.isNotEmpty) {
      final out = await _backend.answerWithKbContextViaBackend(
        backendBaseUrl: backendUrl,
        userQuestion: cleaned,
        knowledgeHits: hits,
      );
      final aiText = out.reply;
      if (aiText != null && aiText.isNotEmpty) {
        // Sources memang tetap dibuat di sini, tapi UI sudah disembunyikan dan ChatState tidak menyimpan sources.
        final sources = <BotSource>[
          const BotSource(
            id: 'hf-backend',
            title: 'Hugging Face (server POLA)',
            excerpt: 'Lewat backend Anda',
            url: null,
          ),
          ...hits.map(
            (h) => BotSource(
              id: h.sourceId,
              title: h.sourceTitle,
              excerpt: _shorten(h.text, 180),
              url: null,
            ),
          ),
        ];
        return BotReply(text: aiText, sources: sources);
      }

      // Jika backend dikonfigurasi tapi gagal/empty, biarkan caller memutuskan retry (loading terus).
      throw Exception(out.hint ?? 'AI backend gagal memberikan jawaban.');
    }

    // 2) Admin FAQ (setelah AI tidak menjawab).
    final admin = await _adminStore.load();
    final adminHit = _matchAdmin(cleaned, admin);
    if (adminHit != null) {
      return BotReply(
        text: adminHit.answer.trim(),
        sources: [
          BotSource(
            id: 'admin:${adminHit.id}',
            title: 'Admin FAQ',
            excerpt: _shorten(adminHit.question, 180),
            url: null,
          ),
        ],
      );
    }

    if (hits.isEmpty) {
      if (PolibatamScope.isAttachmentOnlyPrompt(cleaned)) {
        return BotReply(
          text: _fmt.formatAttachmentNeedsPolibatamQuestion(),
          sources: const [],
        );
      }
      if (!PolibatamScope.isScoped(cleaned)) {
        return BotReply(
          text: _fmt.formatOutOfScopePolibatam(),
          sources: const [],
        );
      }

      // Web fallback (prefer Google CSE if enabled + configured) — hanya jika konteks Polibatam.
      final apiKey = googleApiKey.trim();
      final cx = googleCx.trim();
      if (webSearchEnabled && apiKey.isNotEmpty && cx.isNotEmpty) {
        try {
          final results = await _google.search(
            apiKey: apiKey,
            cx: cx,
            query: cleaned,
            limit: 5,
          );
          if (results.isNotEmpty) {
            final answer = _fmt.formatWebGoogle(
              question: cleaned,
              results: results,
            );
            final sources = results
                .map(
                  (r) => BotSource(
                    id: 'google:${r.url}',
                    title: r.displayLink.isNotEmpty
                        ? '${r.title} • ${r.displayLink}'
                        : r.title,
                    excerpt: _shorten(r.snippet, 180),
                    url: r.url,
                  ),
                )
                .toList();
            return BotReply(text: answer, sources: sources);
          }
        } catch (_) {
          // Fall through to free web fallback below.
        }
      }

      final web = await _web.search(cleaned, limit: 4);
      if (web.isEmpty) {
        return BotReply(
          text: _fmt.formatFallbackSmart(cleaned),
          sources: const [],
        );
      }

      final answer = _fmt.formatWebFree(question: cleaned, results: web);
      final sources = web
          .map(
            (r) => BotSource(
              id: 'web:${r.source}:${r.url}',
              title: '${r.title} (${r.source})',
              excerpt: _shorten(r.snippet, 180),
              url: r.url,
            ),
          )
          .toList();

      return BotReply(text: answer, sources: sources);
    }

    final topHits = hits.length > 3 ? hits.sublist(0, 3) : hits;
    final answer = _fmt.formatLocal(question: cleaned, hits: topHits);
    final sources = topHits
        .map(
          (h) => BotSource(
            id: h.sourceId,
            title: h.sourceTitle,
            excerpt: _shorten(h.text, 180),
            url: null,
          ),
        )
        .toList();

    return BotReply(text: answer, sources: sources);
  }

  static AdminKbEntry? _matchAdmin(
    String question,
    List<AdminKbEntry> entries,
  ) {
    final q = _tokens(question);
    if (q.isEmpty) return null;

    AdminKbEntry? best;
    var bestScore = 0.0;

    for (final e in entries) {
      final t = _tokens('${e.question} ${e.answer}');
      if (t.isEmpty) continue;
      final overlap = q.where(t.contains).length;
      if (overlap == 0) continue;
      final score = overlap / (q.length.clamp(1, 9999));
      if (score > bestScore) {
        bestScore = score;
        best = e;
      }
    }

    // threshold: require at least 2 token overlaps or decent ratio
    if (best == null) return null;
    final bestTokens = _tokens('${best.question} ${best.answer}');
    final overlap = q.where(bestTokens.contains).length;
    if (overlap >= 2 || bestScore >= 0.45) return best;
    return null;
  }

  static Set<String> _tokens(String s) {
    final t = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\u00C0-\u024F\u1E00-\u1EFF ]'), ' ')
        .split(RegExp(r'\s+'))
        .map((x) => x.trim())
        .where((x) => x.length >= 3)
        .toSet();
    t.removeWhere((x) => _stop.contains(x));
    return t;
  }

  static const Set<String> _stop = {
    'yang',
    'dan',
    'atau',
    'untuk',
    'dari',
    'dengan',
    'pada',
    'ini',
    'itu',
    'saya',
    'kamu',
    'anda',
    'kami',
    'mohon',
    'tolong',
    'cara',
    'bagaimana',
    'apa',
    'jadi',
  };

  static String _shorten(String text, int maxLen) {
    final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen)}…';
  }
}
