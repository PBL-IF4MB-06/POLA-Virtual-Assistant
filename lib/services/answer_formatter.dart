import '../services/web_search.dart';
import 'google_cse.dart';
import 'knowledge_base.dart';

enum AnswerCategory { akademik, keuangan, fasilitas, pbl, umum }

class AnswerFormatter {
  const AnswerFormatter();

  String formatLocal({
    required String question,
    required List<KnowledgeSnippet> hits,
  }) {
    final category = _categoryOf(question);
    final title = _titleOf(question, category);
    final bullets = _extractBullets(hits.map((h) => h.text).toList());

    final b = StringBuffer();
    b.writeln('## $title');
    b.writeln(_categoryLabel(category));
    b.writeln();
    for (final item in bullets.take(6)) {
      b.writeln('- $item');
    }
    return b.toString().trim();
  }

  String formatWebGoogle({
    required String question,
    required List<GoogleCseResult> results,
  }) {
    final category = _categoryOf(question);
    final title = _titleOf(question, category);
    final bullets = results
        .map((r) => r.snippet.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => _shorten(s, 240))
        .toList();

    final b = StringBuffer();
    b.writeln('## $title');
    b.writeln(_categoryLabel(category));
    b.writeln();
    b.writeln('Ringkasan berdasarkan sumber web:');
    for (final item in bullets.take(6)) {
      b.writeln('- $item');
    }
    return b.toString().trim();
  }

  String formatWebFree({
    required String question,
    required List<WebSearchResult> results,
  }) {
    final category = _categoryOf(question);
    final title = _titleOf(question, category);
    final bullets = results
        .map((r) => r.snippet.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => _shorten(s, 240))
        .toList();

    final b = StringBuffer();
    b.writeln('## $title');
    b.writeln(_categoryLabel(category));
    b.writeln();
    for (final item in bullets.take(6)) {
      b.writeln('- $item');
    }
    return b.toString().trim();
  }

  String formatOutOfScopePolibatam() {
    return '''
## Di luar lingkup POLA

POLA hanya membahas informasi terkait **Politeknik Negeri Batam (Polibatam)**.

Silakan ajukan pertanyaan seputar kampus (misalnya jadwal, UKT, PMB, prodi, fasilitas, atau kontak), dan sebut **Polibatam** atau **Politeknik Negeri Batam** bila perlu agar pencarian sumber web (jika diaktifkan) tetap relevan.'''
        .trim();
  }

  String formatAttachmentNeedsPolibatamQuestion() {
    return '''
## Perlu pertanyaan terkait Polibatam

POLA hanya membantu topik **Polibatam**. Setelah lampiran, tulis juga pertanyaan singkat yang jelas, misalnya prosedur atau dokumen apa di kampus yang ingin ditanyakan.'''
        .trim();
  }

  String formatFallbackSmart(String question) {
    final category = _categoryOf(question);
    final title = _titleOf(question, category);
    final b = StringBuffer();
    b.writeln('## $title');
    b.writeln(_categoryLabel(category));
    b.writeln();
    b.writeln('Maaf, aku belum bisa memastikan jawaban dari sumber yang tersedia.');
    b.writeln();
    b.writeln('Coba pilih salah satu:');
    for (final s in _fallbackOptions(category)) {
      b.writeln('- $s');
    }
    return b.toString().trim();
  }

  static String _shorten(String text, int maxLen) {
    final t = text.replaceAll(RegExp(r'\\s+'), ' ').trim();
    if (t.length <= maxLen) return t;
    return '${t.substring(0, maxLen)}…';
  }

  static AnswerCategory _categoryOf(String q) {
    final s = q.toLowerCase();
    if (s.contains('beasiswa') || s.contains('biaya') || s.contains('ukt')) {
      return AnswerCategory.keuangan;
    }
    if (s.contains('lab') || s.contains('laboratorium') || s.contains('fasilitas')) {
      return AnswerCategory.fasilitas;
    }
    if (s.contains('pbl') || s.contains('project')) return AnswerCategory.pbl;
    if (s.contains('jadwal') ||
        s.contains('cuti') ||
        s.contains('remed') ||
        s.contains('kehadiran') ||
        s.contains('akademik')) {
      return AnswerCategory.akademik;
    }
    return AnswerCategory.umum;
  }

  static String _titleOf(String q, AnswerCategory c) {
    return switch (c) {
      AnswerCategory.keuangan => 'Keuangan & Beasiswa',
      AnswerCategory.fasilitas => 'Fasilitas & Laboratorium',
      AnswerCategory.pbl => 'PBL (Project Based Learning)',
      AnswerCategory.akademik => 'Akademik',
      AnswerCategory.umum => 'Informasi Polibatam',
    };
  }

  static String _categoryLabel(AnswerCategory c) {
    return switch (c) {
      AnswerCategory.akademik => 'Kategori: Akademik',
      AnswerCategory.keuangan => 'Kategori: Keuangan',
      AnswerCategory.fasilitas => 'Kategori: Fasilitas',
      AnswerCategory.pbl => 'Kategori: PBL',
      AnswerCategory.umum => 'Kategori: Umum',
    };
  }

  static List<String> _fallbackOptions(AnswerCategory c) {
    return switch (c) {
      AnswerCategory.akademik => [
          'Sebutkan program studi dan semester kamu.',
          'Yang kamu butuhkan: jadwal, cuti, remedial, atau kehadiran?',
          'Aktifkan Google CSE di Settings supaya aku bisa ambil sumber resmi web.',
        ],
      AnswerCategory.keuangan => [
          'Kamu cari beasiswa jenis apa? (KIP/industri/internal)',
          'Sebutkan semester & kondisi (IPK/UKT) jika relevan.',
          'Aktifkan Google CSE di Settings untuk sumber resmi.',
        ],
      AnswerCategory.fasilitas => [
          'Lab apa yang dimaksud? (komputer/robotika/manufaktur/dll)',
          'Kebutuhannya: peminjaman, SOP, atau ketersediaan?',
          'Aktifkan Google CSE di Settings untuk sumber resmi.',
        ],
      AnswerCategory.pbl => [
          'Sebutkan topik PBL dan durasi (mis. 8 minggu).',
          'Tim kamu berapa orang dan lintas jurusan apa?',
          'Mau output: milestone, peran tim, atau checklist laporan?',
        ],
      AnswerCategory.umum => [
          'Tuliskan pertanyaan lebih spesifik (contoh: biaya, prodi, kontak).',
          'Aktifkan Google CSE di Settings supaya sources web bisa dipakai.',
        ],
    };
  }

  static List<String> _extractBullets(List<String> texts) {
    final out = <String>[];
    for (final t in texts) {
      final lines = t.split(RegExp(r'\\r?\\n'));
      for (final line in lines) {
        final x = line.trim();
        if (x.isEmpty) continue;
        if (x.startsWith('- ') || x.startsWith('• ')) {
          out.add(x.replaceFirst(RegExp(r'^[-•]\\s+'), '').trim());
        }
      }
      // Fallback: kalau tidak ada bullet, ambil 1–2 kalimat pembuka.
      if (out.isEmpty) {
        final flat = t.replaceAll(RegExp(r'\\s+'), ' ').trim();
        if (flat.isNotEmpty) out.add(_shorten(flat, 260));
      }
    }
    return out;
  }
}

