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
      add('Di Polibatam, di mana sumber resmi kalender akademik & jadwal kuliah?');
      add('Prosedur PBL di Polibatam untuk prodi saya—apa dokumen/milestone wajib?');
      add('Siapa kontak akademik/prodi Polibatam untuk tanya jadwal atau PBL?');
    }
    if (q.contains('beasiswa')) {
      add('Beasiswa apa saja yang tersedia di Polibatam semester ini?');
      add('Syarat dan jadwal pendaftaran beasiswa internal Polibatam?');
      add('Unit di Polibatam yang menangani beasiswa dan UKT?');
    }
    if (q.contains('lab') || q.contains('laboratorium') || q.contains('alat')) {
      add('SOP peminjaman laboratorium di Polibatam dan kontak PIC-nya?');
      add('Fasilitas lab apa saja yang tersedia di Polibatam untuk prodi saya?');
      add('Aturan keselamatan kerja di lab Polibatam?');
    }
    if (q.contains('cuti') || q.contains('remed') || q.contains('kehadiran')) {
      add('Prosedur cuti akademik resmi di Polibatam?');
      add('Aturan remedial/ujian susulan dan kehadiran di Polibatam?');
      add('Minimal kehadiran untuk UAS di Polibatam menurut sumber resmi?');
    }

    if (out.isEmpty) {
      add('Informasi PMB atau pendaftaran mahasiswa baru Polibatam?');
      add('Kontak unit layanan (akademik, kemahasiswaan) Polibatam?');
      add('Lokasi gedung/fasilitas utama kampus Polibatam?');
      add('Syarat UKT atau pembayaran semester di Polibatam?');
    }

    return out.take(limit).toList();
  }
}

