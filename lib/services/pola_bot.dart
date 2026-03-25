class PolaBot {
  const PolaBot();

  String getResponse(String question) {
    final q = question.toLowerCase();

    // PROFIL & UMUM
    if (q.contains('profil') || q.contains('politeknik negeri batam')) {
      return '''
Profil Singkat Politeknik Negeri Batam (Polibatam):

- Politeknik vokasi negeri yang berlokasi di Batam Center, Kota Batam, Kepulauan Riau.
- Fokus pada pendidikan terapan dan aplikatif untuk menyiapkan lulusan siap kerja di industri nasional maupun global.
- Berdiri tahun 2000, bertransformasi menjadi Politeknik Negeri Batam dan kini menjadi salah satu kampus vokasi unggulan Indonesia.
- Dekat dengan kawasan industri besar sehingga banyak kolaborasi dengan perusahaan mitra.
''';
    }

    if (q.contains('lokasi') || q.contains('alamat kampus')) {
      return '''
Lokasi kampus Polibatam:

- Alamat: Jl. Ahmad Yani, Batam Center, Kota Batam, Kepulauan Riau 29461.
- Telepon: (0778) 469856.
- Website resmi: www.polibatam.ac.id
''';
    }

    if (q.contains('sejarah')) {
      return '''
Sejarah singkat Politeknik Negeri Batam:

- 2000: Berdiri sebagai Politeknik Batam (swasta).
- 2003–2005: Pembangunan dan perpindahan ke kampus baru di Batam Center.
- 2007–2009: Berubah status menjadi Politeknik Negeri Batam.
- 2010–sekarang: Pengembangan prodi teknik, bisnis, kreatif, serta penguatan kerjasama industri dan akreditasi nasional/internasional.
''';
    }

    if (q.contains('visi') || q.contains('misi')) {
      return '''
Visi Polibatam:
“Menjadi Politeknik unggul bertaraf internasional dalam penyelenggaraan pendidikan vokasi.”

Beberapa misi utama:
- Menyelenggarakan pendidikan vokasi berkualitas.
- Menguatkan riset terapan dan pengabdian masyarakat.
- Meningkatkan kerjasama dengan industri nasional dan internasional.
- Menghasilkan lulusan profesional, kompeten, dan berdaya saing global.
''';
    }

    // PROGRAM STUDI & JURUSAN
    if (q.contains('jurusan') || q.contains('prodi') || q.contains('program studi')) {
      return '''
Gambaran umum jurusan dan program studi di Polibatam:

- Teknik Informatika & Mekatronika:
  D3/D4 Informatika, D4 Teknik Robotika, D3 Sistem Informasi, D3 Multimedia & Animasi,
  D4 Rekayasa Perangkat Lunak, D4 Sistem Informasi Kota Cerdas.

- Teknik Elektro:
  D3 Elektronika, D3 Instrumentasi, D3 Teknologi Telekomunikasi, D4 Teknik Elektro.

- Teknik Mesin & Manufaktur:
  D3 Teknik Mesin, D3 Perancangan Mekanik, D4 Manufaktur.

- Administrasi Bisnis:
  D3 Akuntansi, D3 Administrasi Bisnis, D3 Perpajakan,
  D4 Akuntansi Manajemen, D4 Administrasi Bisnis Internasional.

Untuk detail per prodi, biasanya tersedia di website resmi Polibatam.
''';
    }

    if (q.contains('jenjang') || q.contains('d3') || q.contains('d4')) {
      return '''
Jenis jenjang pendidikan di Polibatam:

- D3 (Diploma 3)
- D4 (Sarjana Terapan)
- D2 Fast-Track Industri (hasil kerjasama dengan industri tertentu)
''';
    }

    // PBL & SISTEM PEMBELAJARAN
    if (q.contains('pbl') || q.contains('project based learning')) {
      return '''
Project Based Learning (PBL) di Polibatam:

- Menjadi ciri khas pembelajaran, di mana mahasiswa mengerjakan proyek nyata terkait kebutuhan industri.
- Umumnya dilakukan lintas mata kuliah dan terkadang lintas program studi.
- Mahasiswa menyusun proposal, milestone, logbook, hingga laporan akhir dan presentasi.

POLA dapat membantu Anda menyusun struktur milestone PBL, ide pembagian peran tim, dan checklist laporan akhir.
''';
    }

    if (q.contains('pembelajaran') || q.contains('sistem belajar')) {
      return '''
Sistem pembelajaran di Polibatam:

- Practical-based learning dan Project Based Learning (PBL).
- Work-Based Learning (WBL) dan magang/PKL terstruktur di industri.
- 60–70% pembelajaran berfokus pada praktik di lab, workshop, dan teaching factory.
''';
    }

    // FASILITAS & LAB
    if (q.contains('fasilitas') || q.contains('lab') || q.contains('laboratorium')) {
      return '''
Beberapa fasilitas akademik dan lab di Polibatam:

- Ruang kelas modern, lab komputer, lab robotika, lab manufaktur & CNC,
  lab elektronika, teaching factory (TEFA), auditorium, dan perpustakaan digital.

Fasilitas mahasiswa:
- Poliklinik kampus, masjid, food court/kantin, ruang HIMA, coworking space, lounge diskusi, dan area parkir luas.

Fasilitas olahraga:
- Lapangan futsal, basket, volley, dan gym mini.
''';
    }

    // BEASISWA, MAGANG, KARIR
    if (q.contains('beasiswa')) {
      return '''
Beberapa jenis beasiswa yang biasa tersedia di Polibatam:

- Beasiswa KIP.
- Beasiswa dari industri/mitra kampus.
- Skema bantuan pendidikan lain sesuai kerja sama dan kebijakan tahun berjalan.

Detail kuota, syarat, dan periode pendaftaran biasanya diumumkan melalui situs resmi atau kanal informasi kampus.
''';
    }

    if (q.contains('magang') || q.contains('internship') || q.contains('pkl')) {
      return '''
Magang/PKL di Polibatam:

- Terintegrasi dengan kurikulum vokasi dan sering dilakukan di perusahaan mitra industri.
- Banyak kerja sama dengan perusahaan di kawasan industri Batam dan mitra nasional/internasional.
- Informasi lowongan magang biasanya difasilitasi oleh Career Center & Training (CCT) dan program studi.
''';
    }

    if (q.contains('karir') || q.contains('career center')) {
      return '''
Layanan karir di Polibatam:

- Difasilitasi oleh Career Center & Training (CCT).
- Menyediakan informasi lowongan kerja/magang, pelatihan soft-skill, dan kegiatan rekrutmen kampus (campus hiring).
''';
    }

    // KEHIDUPAN KAMPUS & UKM
    if (q.contains('ukm') || q.contains('unit kegiatan mahasiswa') || q.contains('organisasi mahasiswa')) {
      return '''
Kehidupan mahasiswa di Polibatam:

- Ada Himpunan Mahasiswa (HIMA) di setiap program studi.
- Unit Kegiatan Mahasiswa (UKM) beragam, misalnya: musik, robotika, PSM, olahraga, broadcast & cinematography, pecinta alam, dan e-sport.

Mahasiswa dapat bergabung untuk mengembangkan minat, bakat, dan jejaring pertemanan.
''';
    }

    // AKADEMIK & PERATURAN
    if (q.contains('peraturan akademik') ||
        q.contains('kehadiran uas') ||
        q.contains('cuti akademik') ||
        q.contains('remedial')) {
      return '''
Beberapa contoh aspek peraturan akademik di Polibatam:

- Minimal kehadiran perkuliahan biasanya disyaratkan agar dapat mengikuti ujian (detail persentase lihat buku pedoman akademik).
- Prosedur cuti akademik dilakukan melalui pengajuan resmi ke bagian akademik dan persetujuan pimpinan.
- Aturan teknis terkait UTS/UAS, remedial, dan yudisium diatur dalam panduan akademik resmi.

Untuk angka pasti (misalnya persentase kehadiran), silakan rujuk dokumen peraturan akademik Polibatam terbaru.
''';
    }

    // AKREDITASI & KEUNGGULAN
    if (q.contains('akreditasi')) {
      return '''
Akreditasi Polibatam secara umum:

- Akreditasi institusi: Baik Sekali (BAN-PT).
- Beberapa program studi memiliki akreditasi Unggul dan bahkan akreditasi internasional.
- Contoh: Teknik Robotika terakreditasi internasional (IABEE), Informatika terakreditasi nasional Unggul, dan sejumlah prodi teknik/manufaktur dengan Baik Sekali.
''';
    }

    if (q.contains('kelebihan') || q.contains('kenapa') && q.contains('polibatam')) {
      return '''
Beberapa kelebihan kuliah di Polibatam:

- Kampus vokasi unggulan di Kepulauan Riau dengan fokus praktik tinggi.
- Lokasi dekat kawasan industri global di Batam, membuka banyak peluang magang dan kerja.
- Fasilitas lab dan teaching factory lengkap.
- Banyak kerja sama industri dan program fast-track ke perusahaan mitra.
''';
    }

    // JADWAL & ADMIN AKADEMIK
    if (q.contains('jadwal')) {
      return '''
Berikut informasi umum terkait jadwal perkuliahan di Polibatam:

1. Jadwal perkuliahan resmi dapat diakses melalui sistem akademik kampus (SIAKAD).
2. Perubahan jadwal (ruangan/dosen) biasanya diumumkan melalui sistem atau grup resmi program studi.
3. Untuk jadwal terkini, silakan login ke akun mahasiswa Anda di sistem akademik.
''';
    }
    if (q.contains('biaya')) {
      return '''
Terkait biaya kuliah di Polibatam:

- Rincian biaya per program studi tersedia di website resmi Polibatam, bagian informasi keuangan.
- Informasi cicilan atau skema pembayaran bisa dikonsultasikan langsung dengan bagian keuangan kampus.
- Untuk informasi paling akurat, silakan cek pengumuman resmi tahun akademik yang sedang berjalan.
''';
    }
    if (q.contains('pendaftaran') || q.contains('pmb')) {
      return '''
Informasi pendaftaran mahasiswa baru (PMB) Polibatam:

1. Kunjungi halaman resmi PMB Polibatam untuk melihat jalur masuk, jadwal, dan persyaratan.
2. Siapkan dokumen seperti ijazah/rapor, identitas, dan berkas pendukung lainnya sesuai ketentuan.
3. Ikuti alur pendaftaran yang dijelaskan di website, termasuk pembuatan akun, pengisian data, dan upload dokumen.
''';
    }
    if (q.contains('kontak') || q.contains('hubungi')) {
      return '''
Untuk menghubungi Polibatam:

- Gunakan nomor kontak resmi dan alamat email yang tercantum di website utama Polibatam.
- Anda juga bisa menghubungi bagian akademik, keuangan, atau program studi terkait melalui kontak yang disediakan.
''';
    }

    // FALLBACK
    return '''
Terima kasih atas pertanyaannya.

Untuk informasi lebih lengkap dan resmi, silakan kunjungi website Polibatam atau hubungi bagian terkait di kampus. Jika mau, Anda bisa menanyakan hal yang lebih spesifik, misalnya:
- Jadwal kuliah prodi tertentu
- Detail biaya per semester
- Syarat pendaftaran jalur tertentu
''';
  }
}
