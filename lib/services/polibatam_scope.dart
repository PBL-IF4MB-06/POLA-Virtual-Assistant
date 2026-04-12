/// Menentukan apakah pertanyaan masih dalam konteks Politeknik Negeri Batam (Polibatam).
///
/// Knowledge base & admin FAQ dianggap sudah berisi materi kampus; gate ini
/// terutama memblokir **web fallback** untuk topik umum di luar Polibatam.
class PolibatamScope {
  PolibatamScope._();

  static bool isScoped(String question) {
    final s = question.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (s.contains('polibatam')) return true;
    if (s.contains('politeknik negeri batam')) return true;
    if (s.contains('politeknik batam')) return true;
    if (s.contains('pn batam')) return true;
    if (s.contains('politeknik') && s.contains('batam')) return true;
    return false;
  }

  /// Prompt dari [ChatState] saat pengguna hanya mengirim lampiran tanpa teks.
  static bool isAttachmentOnlyPrompt(String question) {
    final t = question.trim();
    return t.startsWith('Konteks tambahan:') && t.contains('mengirim lampiran');
  }
}
