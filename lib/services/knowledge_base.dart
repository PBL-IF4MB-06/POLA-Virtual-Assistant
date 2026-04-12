import 'dart:math';

import 'package:flutter/services.dart';

class KnowledgeSource {
  const KnowledgeSource({
    required this.id,
    required this.title,
    required this.assetPath,
  });

  final String id;
  final String title;
  final String assetPath;
}

class KnowledgeSnippet {
  const KnowledgeSnippet({
    required this.sourceId,
    required this.sourceTitle,
    required this.text,
    required this.score,
  });

  final String sourceId;
  final String sourceTitle;
  final String text;
  final double score;
}

class KnowledgeBase {
  KnowledgeBase({
    List<KnowledgeSource>? sources,
  }) : _sources = sources ??
            const [
              KnowledgeSource(
                id: 'desain-umum',
                title: 'Desain Umum Sistem (POLA)',
                assetPath: 'assets/keterangan_desain_umum_sistem.txt',
              ),
            ];

  final List<KnowledgeSource> _sources;

  bool _loaded = false;
  final List<_IndexedSnippet> _snippets = [];
  final Map<String, int> _docFreq = {};
  var _avgDocLen = 0.0;
  static const double _k1 = 1.2;
  static const double _b = 0.75;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;

    for (final src in _sources) {
      String raw;
      try {
        raw = await rootBundle.loadString(src.assetPath);
      } catch (_) {
        // Jika asset tidak tersedia di build runtime, jangan bikin bot crash.
        // Biarkan knowledge base kosong agar pipeline fallback ke web.
        continue;
      }

      final parts = _splitIntoSnippets(raw);
      for (final p in parts) {
        final tokens = _tokenize(p);
        if (tokens.isEmpty) continue;
        final tf = <String, int>{};
        for (final t in tokens) {
          tf[t] = (tf[t] ?? 0) + 1;
        }
        for (final term in tf.keys) {
          _docFreq[term] = (_docFreq[term] ?? 0) + 1;
        }
        _snippets.add(
          _IndexedSnippet(
            sourceId: src.id,
            sourceTitle: src.title,
            text: p,
            termFreq: tf,
            docLen: tokens.length,
          ),
        );
      }
    }

    if (_snippets.isEmpty) {
      _avgDocLen = 0;
      return;
    }
    final totalLen = _snippets.fold<int>(0, (sum, s) => sum + s.docLen);
    _avgDocLen = totalLen / _snippets.length;
  }

  List<KnowledgeSnippet> search(String query, {int limit = 3}) {
    if (!_loaded) {
      throw StateError('KnowledgeBase belum diload. Panggil ensureLoaded().');
    }

    final qTokens = _expandQuery(_tokenize(query));
    if (qTokens.isEmpty) return const [];

    final scored = <KnowledgeSnippet>[];
    for (final s in _snippets) {
      final score = _bm25(qTokens, s);
      if (score <= 0) continue;
      scored.add(
        KnowledgeSnippet(
          sourceId: s.sourceId,
          sourceTitle: s.sourceTitle,
          text: s.text,
          score: score,
        ),
      );
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.isEmpty) return const [];

    final top = scored.first.score;
    // Threshold: kalau terlalu rendah, lebih baik "nggak ketemu" daripada ngawur.
    if (top < 1.15) return const [];

    final filtered = scored.where((s) => s.score >= (top * 0.72)).toList();
    return filtered.take(max(1, min(limit, filtered.length))).toList();
  }

  static List<String> _splitIntoSnippets(String raw) {
    final cleaned = raw
        .replaceAll('\r\n', '\n')
        .replaceAll('\t', ' ')
        .replaceAll(RegExp(r'[ ]+'), ' ')
        .trim();

    final blocks = cleaned.split(RegExp(r'\n\s*\n'));
    final out = <String>[];
    for (final b in blocks) {
      final t = b.trim();
      if (t.isEmpty) continue;
      // Potong blok yang terlalu panjang biar snippet nyaman dibaca.
      if (t.length <= 560) {
        out.add(t);
        continue;
      }

      final sentences = t.split(RegExp(r'(?<=[\.\!\?])\s+'));
      var buf = StringBuffer();
      for (final s in sentences) {
        final next = s.trim();
        if (next.isEmpty) continue;
        if ((buf.length + next.length + 1) > 560) {
          if (buf.isNotEmpty) out.add(buf.toString().trim());
          buf = StringBuffer();
        }
        buf.write(next);
        buf.write(' ');
      }
      final tail = buf.toString().trim();
      if (tail.isNotEmpty) out.add(tail);
    }
    return out;
  }

  static List<String> _tokenize(String text) {
    final lower = text.toLowerCase();
    final words = lower
        .replaceAll(RegExp(r'[^a-z0-9\u00C0-\u024F\s]'), ' ')
        .split(RegExp(r'\s+'))
        .map((w) => w.trim())
        .where((w) => w.length >= 3);

    final stop = _stopWords;
    final out = <String>[];
    for (final w in words) {
      if (stop.contains(w)) continue;
      out.add(_normalize(w));
    }
    return out;
  }

  static String _normalize(String w) {
    // Normalisasi ringan supaya Indonesian-ish lebih stabil.
    var x = w;
    if (x.endsWith('nya') && x.length > 5) x = x.substring(0, x.length - 3);
    if (x.endsWith('lah') && x.length > 5) x = x.substring(0, x.length - 3);
    if (x.endsWith('kah') && x.length > 5) x = x.substring(0, x.length - 3);
    if (x.endsWith('pun') && x.length > 5) x = x.substring(0, x.length - 3);
    if (x.endsWith('kan') && x.length > 6) x = x.substring(0, x.length - 3);
    if (x.endsWith('annya') && x.length > 8) x = x.substring(0, x.length - 5);
    return x;
  }

  static List<String> _expandQuery(List<String> q) {
    final out = <String>[...q];
    for (final t in q) {
      final extra = _synonyms[t];
      if (extra == null) continue;
      out.addAll(extra);
    }
    return out;
  }

  double _bm25(List<String> qTokens, _IndexedSnippet doc) {
    if (_avgDocLen <= 0) return 0;
    final n = _snippets.length;
    var score = 0.0;
    final qUnique = qTokens.toSet();
    for (final term in qUnique) {
      final tf = doc.termFreq[term] ?? 0;
      if (tf == 0) continue;
      final df = _docFreq[term] ?? 0;
      if (df == 0) continue;
      final idf = log(((n - df + 0.5) / (df + 0.5)) + 1);
      final dl = doc.docLen.toDouble();
      final denom = tf + _k1 * (1 - _b + _b * (dl / _avgDocLen));
      score += idf * (tf * (_k1 + 1)) / denom;
    }
    return score;
  }
}

class _IndexedSnippet {
  const _IndexedSnippet({
    required this.sourceId,
    required this.sourceTitle,
    required this.text,
    required this.termFreq,
    required this.docLen,
  });

  final String sourceId;
  final String sourceTitle;
  final String text;
  final Map<String, int> termFreq;
  final int docLen;
}

const Set<String> _stopWords = {
  'yang',
  'dan',
  'atau',
  'untuk',
  'dengan',
  'pada',
  'dari',
  'dalam',
  'sebagai',
  'oleh',
  'ini',
  'itu',
  'jadi',
  'agar',
  'bagi',
  'kamu',
  'saya',
  'kami',
  'anda',
  'lebih',
  'juga',
  'akan',
  'bisa',
  'dapat',
  'serta',
  'hanya',
  'sudah',
  'belum',
  'pula',
  'nya',
  'dll',
};

const Map<String, List<String>> _synonyms = {
  'admin': ['administrator', 'dasbor', 'dashboard', 'kelola', 'mengelola'],
  'administrator': ['admin', 'dasbor', 'dashboard', 'kelola', 'mengelola'],
  'pengguna': ['user', 'mahasiswa', 'tamu', 'guest'],
  'user': ['pengguna', 'mahasiswa', 'tamu', 'guest'],
  'database': ['basis', 'data', 'sql', 'json', 'key', 'value'],
  'basis': ['database', 'data'],
  'percakapan': ['chat', 'dialog', 'utas', 'thread'],
  'chat': ['percakapan', 'dialog', 'utas', 'thread'],
  'fitur': ['kapabilitas', 'modul', 'fungsi'],
  'modul': ['fitur', 'kapabilitas', 'fungsi'],
};

