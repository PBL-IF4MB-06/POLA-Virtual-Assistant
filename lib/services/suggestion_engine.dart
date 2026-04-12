class SuggestionEngine {
  const SuggestionEngine();

  List<String> suggestFollowUps(String lastUserMessage, {int limit = 4}) {
    final q = lastUserMessage.toLowerCase();
    final out = <String>[];

    void add(String s) {
      if (out.contains(s)) return;
      out.add(s);
    }

    // Intent ringan: kita tidak “ngarang”, hanya menyarankan langkah lanjut.
    if (q.contains('jadwal') || q.contains('pbl')) {
      add('Saya kuliah prodi X. Tolong buat checklist mingguan untuk PBL + jadwal.');
      add('Buat template milestone PBL 8 minggu + pembagian peran tim.');
      add('Sumber resmi jadwal/kalender akademik Polibatam di mana?');
    }
    if (q.contains('beasiswa')) {
      add('Sebutkan beasiswa yang relevan untuk semester ini dan syarat umumnya.');
      add('Tolong buat daftar dokumen yang biasanya dibutuhkan untuk daftar beasiswa.');
      add('Sumber resmi info beasiswa Polibatam apa?');
    }
    if (q.contains('lab') || q.contains('laboratorium') || q.contains('alat')) {
      add('Jelaskan SOP peminjaman lab + siapa PIC-nya (sertakan sumber).');
      add('Tolong buat form permohonan peminjaman lab (template).');
      add('Apa saja aturan keselamatan kerja di lab?');
    }
    if (q.contains('cuti') || q.contains('remed') || q.contains('kehadiran')) {
      add('Ringkas prosedur cuti akademik langkah demi langkah + sumber.');
      add('Apa aturan remedial/ujian susulan dan syaratnya?');
      add('Minimal kehadiran untuk ikut UAS berapa? (sertakan sumber).');
    }

    if (out.isEmpty) {
      add('Tolong ringkas jawaban dalam 5 poin dan cantumkan sources.');
      add('Buatkan langkah-langkah praktis yang bisa langsung saya lakukan.');
      add('Kalau ada aturan resmi, sebutkan dari sumber mana.');
      add('Ajukan 3 pertanyaan klarifikasi agar jawabannya lebih tepat.');
    }

    return out.take(limit).toList();
  }
}

