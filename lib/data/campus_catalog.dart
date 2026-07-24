import 'package:flutter/material.dart';

enum CampusInfoCategory { akademik, kampus, bantuan }

class CampusInfoModule {
  const CampusInfoModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.sections,
    required this.chatPrompt,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final CampusInfoCategory category;
  final List<({String heading, String body})> sections;
  final String chatPrompt;
}

class CampusCatalog {
  static const all = <CampusInfoModule>[
    // —— Modul Informasi Akademik ——
    CampusInfoModule(
      id: 'kalender_akademik',
      title: 'Kalender Akademik',
      subtitle: 'Semester, UTS, UAS, libur',
      icon: Icons.calendar_month_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Ringkasan',
          body:
              'Kalender akademik Polibatam memuat jadwal semester, periode KRS, UTS, UAS, '
              'libur nasional, dan kegiatan kampus. Mahasiswa wajib memantau kalender resmi setiap semester.',
        ),
        (
          heading: 'Akses',
          body:
              'Kalender terbaru biasanya diumumkan melalui portal akademik dan website resmi Polibatam. '
              'Tanyakan POLA untuk detail periode semester berjalan.',
        ),
      ],
      chatPrompt: 'Kapan periode KRS dan UTS/UAS semester ini di Polibatam?',
    ),
    CampusInfoModule(
      id: 'jadwal_kuliah',
      title: 'Jadwal Kuliah',
      subtitle: 'Kelas harian mahasiswa',
      icon: Icons.schedule_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Cara Cek',
          body:
              'Jadwal kuliah dapat dilihat melalui Sistem Informasi Akademik (SIA) setelah login '
              'menggunakan akun mahasiswa. Pastikan KRS sudah disetujui dosen wali.',
        ),
        (
          heading: 'Jadwal Hari Ini',
          body:
              'Dashboard POLA menampilkan ringkasan jadwal hari ini. Untuk jadwal lengkap per mata kuliah, '
              'gunakan portal resmi atau tanyakan POLA dengan menyebut program studi Anda.',
        ),
      ],
      chatPrompt: 'Bagaimana cara melihat jadwal kuliah saya di Polibatam?',
    ),
    CampusInfoModule(
      id: 'jadwal_uts_uas',
      title: 'Jadwal UTS/UAS',
      subtitle: 'Ujian tengah & akhir semester',
      icon: Icons.fact_check_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Informasi',
          body:
              'Jadwal UTS dan UAS diumumkan oleh bagian akademik mendekati periode ujian. '
              'Mahasiswa wajib memeriksa ruang, waktu, dan ketentuan kehadiran.',
        ),
        (
          heading: 'Ketentuan Umum',
          body:
              'Bawa kartu mahasiswa, patuhi aturan kejujuran akademik, dan hadir sesuai jadwal. '
              'Jika berhalangan, ajukan surat keterangan sesuai prosedur kampus.',
        ),
      ],
      chatPrompt: 'Kapan jadwal UTS dan UAS semester ini di Polibatam?',
    ),
    CampusInfoModule(
      id: 'informasi_krs',
      title: 'Informasi KRS',
      subtitle: 'Kartu Rencana Studi',
      icon: Icons.edit_note_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Pengertian',
          body:
              'KRS adalah daftar mata kuliah yang diambil mahasiswa pada satu semester. '
              'Pengisian KRS dilakukan online melalui SIA pada periode yang ditetapkan.',
        ),
        (
          heading: 'Alur Singkat',
          body:
              '1) Konsultasi dosen wali → 2) Isi KRS di SIA → 3) Persetujuan dosen wali → '
              '4) Verifikasi bagian akademik. Pastikan SKS sesuai batas yang berlaku.',
        ),
      ],
      chatPrompt: 'Kapan jadwal KRS semester ini dan bagaimana prosedurnya di Polibatam?',
    ),
    CampusInfoModule(
      id: 'informasi_khs',
      title: 'Informasi KHS',
      subtitle: 'Kartu Hasil Studi',
      icon: Icons.assessment_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Fungsi',
          body:
              'KHS menampilkan nilai per mata kuliah, IP semester, dan IPK. '
              'Dokumen ini digunakan untuk evaluasi studi dan pengajuan beasiswa.',
        ),
        (
          heading: 'Akses',
          body:
              'KHS dapat diunduh dari portal akademik setelah nilai dipublikasikan. '
              'Hubungi bagian akademik jika ada ketidaksesuaian nilai.',
        ),
      ],
      chatPrompt: 'Bagaimana cara melihat dan mengunduh KHS di Polibatam?',
    ),
    CampusInfoModule(
      id: 'pkl_magang',
      title: 'PKL / Magang',
      subtitle: 'Praktik kerja lapangan',
      icon: Icons.work_outline_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Tujuan',
          body:
              'PKL/magang memberikan pengalaman industri kepada mahasiswa sesuai kompetensi program studi. '
              'Pelaksanaan mengikuti kurikulum dan panduan prodi.',
        ),
        (
          heading: 'Persyaratan Umum',
          body:
              'Mahasiswa umumnya harus memenuhi syarat SKS/minimum IPK, mengajukan proposal, '
              'dan mendapat persetujuan dosen pembimbing. Detail tiap prodi dapat berbeda.',
        ),
      ],
      chatPrompt: 'Apa persyaratan dan prosedur PKL/magang di Polibatam?',
    ),
    CampusInfoModule(
      id: 'pbl',
      title: 'Informasi PBL',
      subtitle: 'Project Based Learning',
      icon: Icons.groups_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Konsep',
          body:
              'PBL adalah metode pembelajaran berbasis proyek yang diterapkan di Polibatam. '
              'Mahasiswa menyelesaikan masalah nyata secara berkelompok dengan bimbingan dosen.',
        ),
        (
          heading: 'Tips Sukses',
          body:
              'Aktif dalam kelompok, dokumentasikan progres, patuhi jadwal presentasi, '
              'dan manfaatkan fasilitas lab sesuai kebutuhan proyek.',
        ),
      ],
      chatPrompt: 'Jelaskan alur PBL dan penilaiannya di Polibatam.',
    ),
    CampusInfoModule(
      id: 'tugas_akhir',
      title: 'Tugas Akhir',
      subtitle: 'Skripsi / proyek akhir',
      icon: Icons.school_rounded,
      category: CampusInfoCategory.akademik,
      sections: [
        (
          heading: 'Tahapan',
          body:
              'Tugas akhir meliputi pengajuan judul, seminar proposal, bimbingan, '
              'pengujian, dan publikasi laporan sesuai panduan prodi.',
        ),
        (
          heading: 'Dukungan Kampus',
          body:
              'Gunakan laboratorium, konsultasi dosen pembimbing, dan perpustakaan kampus. '
              'Tanyakan POLA untuk template panduan resmi prodi Anda.',
        ),
      ],
      chatPrompt: 'Apa tahapan tugas akhir di Polibatam untuk program studi saya?',
    ),
    // —— Modul Informasi Kampus ——
    CampusInfoModule(
      id: 'profil_polibatam',
      title: 'Profil Polibatam',
      subtitle: 'Politeknik Negeri Batam',
      icon: Icons.account_balance_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Tentang',
          body:
              'Politeknik Negeri Batam (Polibatam) adalah perguruan tinggi vokasi negeri di Kota Batam '
              'yang menyiapkan lulusan siap kerja di bidang teknik, bisnis, dan teknologi.',
        ),
        (
          heading: 'Fokus',
          body:
              'Pendidikan vokasi berbasis kompetensi, kerja sama industri, dan pengembangan '
              'kemampuan praktik melalui lab, magang, dan PBL.',
        ),
      ],
      chatPrompt: 'Ceritakan profil singkat Politeknik Negeri Batam.',
    ),
    CampusInfoModule(
      id: 'visi_misi',
      title: 'Visi dan Misi',
      subtitle: 'Arah dan tujuan kampus',
      icon: Icons.flag_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Visi',
          body:
              'Menjadi politeknik unggulan yang menghasilkan lulusan vokasi berkompetensi global '
              'dan berjiwa entrepreneur di bidang teknologi dan bisnis.',
        ),
        (
          heading: 'Misi',
          body:
              'Menyelenggarakan pendidikan vokasi bermutu, penelitian terapan, pengabdian masyarakat, '
              'dan kerja sama dengan dunia industri.',
        ),
      ],
      chatPrompt: 'Apa visi dan misi Polibatam?',
    ),
    CampusInfoModule(
      id: 'struktur_organisasi',
      title: 'Struktur Organisasi',
      subtitle: 'Pimpinan & unit kerja',
      icon: Icons.hub_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Pimpinan',
          body:
              'Polibatam dipimpin oleh Direktur dengan unsur wakil direktur bidang akademik, '
              'umum & keuangan, serta sumber daya dan kerja sama.',
        ),
        (
          heading: 'Unit',
          body:
              'Unit pendukung meliputi akademik, kemahasiswaan, perpustakaan, pusat bahasa, '
              'dan unit layanan TI kampus.',
        ),
      ],
      chatPrompt: 'Jelaskan struktur organisasi Polibatam.',
    ),
    CampusInfoModule(
      id: 'direktori_prodi',
      title: 'Direktori Program Studi',
      subtitle: 'Jurusan & kompetensi',
      icon: Icons.menu_book_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Program Studi',
          body:
              'Polibatam memiliki berbagai program studi D3 dan D4 di bidang teknik informatika, '
              'teknik mesin, akuntansi, bisnis digital, dan lainnya.',
        ),
        (
          heading: 'Informasi Lanjut',
          body:
              'Setiap prodi memiliki kurikulum, kompetensi lulusan, dan fasilitas lab khusus. '
              'Tanyakan POLA dengan menyebut nama prodi yang Anda minati.',
        ),
      ],
      chatPrompt: 'Apa saja program studi di Polibatam dan profil singkatnya?',
    ),
    CampusInfoModule(
      id: 'direktori_dosen',
      title: 'Direktori Dosen',
      subtitle: 'Dosen & pembimbing',
      icon: Icons.person_search_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Akses',
          body:
              'Daftar dosen per program studi tersedia melalui website kampus dan SIA. '
              'Mahasiswa dapat menghubungi dosen wali atau pembimbing melalui email kampus.',
        ),
        (
          heading: 'Etika',
          body:
              'Gunakan bahasa sopan, sertakan identitas (nama, NIM, kelas), dan jelaskan maksud pertanyaan secara ringkas.',
        ),
      ],
      chatPrompt: 'Bagaimana cara menemukan kontak dosen wali di Polibatam?',
    ),
    CampusInfoModule(
      id: 'direktori_gedung',
      title: 'Direktori Gedung',
      subtitle: 'Lokasi ruang & lab',
      icon: Icons.apartment_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Gedung Utama',
          body:
              'Kampus memiliki beberapa gedung untuk perkuliahan teori, laboratorium, administrasi, '
              'dan pusat kegiatan mahasiswa.',
        ),
        (
          heading: 'Contoh',
          body:
              'Gedung TI, gedung teknik mesin, gedung administrasi, dan area workshop praktikum. '
              'Tanyakan POLA untuk lokasi gedung spesifik (misalnya gedung TI).',
        ),
      ],
      chatPrompt: 'Di mana lokasi gedung TI di kampus Polibatam?',
    ),
    CampusInfoModule(
      id: 'peta_kampus',
      title: 'Peta Kampus',
      subtitle: 'Navigasi area kampus',
      icon: Icons.map_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Petunjuk',
          body:
              'Peta kampus membantu mahasiswa baru menemukan gedung kuliah, perpustakaan, masjid, '
              'kantin, dan kantor administrasi.',
        ),
        (
          heading: 'Tips',
          body:
              'Saat orientasi, ikuti tur kampus. Gunakan POLA untuk menanyakan arah gedung tertentu '
              'dengan menyebut nama gedung atau prodi.',
        ),
      ],
      chatPrompt: 'Bagaimana cara menuju perpustakaan dari gerbang utama Polibatam?',
    ),
    CampusInfoModule(
      id: 'fasilitas_kampus',
      title: 'Fasilitas Kampus',
      subtitle: 'Lab, perpustakaan, wifi',
      icon: Icons.wifi_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Fasilitas Umum',
          body:
              'Perpustakaan, laboratorium, ruang komputer, area bersama, koneksi internet kampus, '
              'dan layanan kemahasiswaan.',
        ),
        (
          heading: 'Peminjaman',
          body:
              'Peminjaman alat/lab mengikuti prosedur prodi masing-masing. Ajukan melalui dosen '
              'atau teknisi lab yang berwenang.',
        ),
      ],
      chatPrompt: 'Apa saja fasilitas kampus Polibatam dan cara mengaksesnya?',
    ),
    // —— Modul Bantuan ——
    CampusInfoModule(
      id: 'faq',
      title: 'FAQ',
      subtitle: 'Pertanyaan umum',
      icon: Icons.quiz_rounded,
      category: CampusInfoCategory.bantuan,
      sections: [
        (
          heading: 'Akademik',
          body:
              '• Kapan KRS dibuka?\n• Bagaimana cuti kuliah?\n• Bagaimana mengulang mata kuliah?\n'
              'Gunakan Chat AI untuk jawaban detail dengan sumber.',
        ),
        (
          heading: 'Kemahasiswaan',
          body:
              '• Beasiswa apa saja yang ada?\n• Cara daftar UKM?\n• Kontak bagian kemahasiswaan?',
        ),
      ],
      chatPrompt: 'Apa prosedur cuti kuliah di Polibatam?',
    ),
    CampusInfoModule(
      id: 'panduan_akademik',
      title: 'Panduan Akademik',
      subtitle: 'Aturan studi',
      icon: Icons.rule_folder_rounded,
      category: CampusInfoCategory.bantuan,
      sections: [
        (
          heading: 'Isi Panduan',
          body:
              'Kehadiran minimum, pengajuan cuti, remedial, penilaian, integritas akademik, '
              'dan ketentuan kelulusan.',
        ),
        (
          heading: 'Sumber',
          body:
              'Panduan resmi diterbitkan oleh bagian akademik setiap tahun akademik. '
              'POLA dapat merangkum poin penting jika Anda bertanya spesifik.',
        ),
      ],
      chatPrompt: 'Ringkas aturan kehadiran dan cuti kuliah di Polibatam.',
    ),
    CampusInfoModule(
      id: 'panduan_sia',
      title: 'Panduan SIA',
      subtitle: 'Sistem Informasi Akademik',
      icon: Icons.computer_rounded,
      category: CampusInfoCategory.bantuan,
      sections: [
        (
          heading: 'Fitur SIA',
          body:
              'Login mahasiswa, KRS, KHS, jadwal kuliah, transkrip, dan pengajuan surat akademik.',
        ),
        (
          heading: 'Masalah Umum',
          body:
              'Lupa password → reset melalui email kampus. Error login → pastikan akun aktif '
              'dan hubungi helpdesk TI kampus.',
        ),
      ],
      chatPrompt: 'Bagaimana cara login dan mengisi KRS di SIA Polibatam?',
    ),
    CampusInfoModule(
      id: 'kontak_kampus',
      title: 'Kontak Kampus',
      subtitle: 'Hubungi bagian terkait',
      icon: Icons.call_rounded,
      category: CampusInfoCategory.bantuan,
      sections: [
        (
          heading: 'Kontak Umum',
          body:
              'Website: polibatam.ac.id\nAlamat: Kota Batam, Kepulauan Riau\n'
              'Hubungi bagian akademik, kemahasiswaan, atau TU sesuai kebutuhan.',
        ),
        (
          heading: 'Darurat Kampus',
          body:
              'Untuk keadaan darurat di area kampus, hubungi satpam atau unit keamanan kampus.',
        ),
      ],
      chatPrompt: 'Apa kontak bagian akademik Polibatam?',
    ),
    // —— Modul Mahasiswa (di bawah Informasi) ——
    CampusInfoModule(
      id: 'beasiswa',
      title: 'Beasiswa',
      subtitle: 'Internal & eksternal',
      icon: Icons.volunteer_activism_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Jenis',
          body:
              'Beasiswa prestasi, KIP, beasiswa industri, dan program pemerintah lain. '
              'Syarat umum: IPK minimum, surat rekomendasi, dan kelengkapan dokumen.',
        ),
        (
          heading: 'Pengumuman',
          body:
              'Pantau tab Pengumuman dan website kampus untuk jadwal pendaftaran terbaru.',
        ),
      ],
      chatPrompt: 'Informasi beasiswa apa saja yang tersedia di Polibatam?',
    ),
    CampusInfoModule(
      id: 'ukm',
      title: 'UKM & Organisasi',
      subtitle: 'Kegiatan kemahasiswaan',
      icon: Icons.diversity_3_rounded,
      category: CampusInfoCategory.kampus,
      sections: [
        (
          heading: 'Kegiatan',
          body:
              'Unit Kegiatan Mahasiswa (UKM) meliputi olahraga, seni, teknologi, dan sosial. '
              'Organisasi kemahasiswaan mengadakan event dan pengembangan soft skill.',
        ),
        (
          heading: 'Pendaftaran',
          body:
              'Pendaftaran UKM dibuka pada periode orientasi atau sesuai pengumuman BEM/kemahasiswaan.',
        ),
      ],
      chatPrompt: 'Apa saja UKM dan organisasi mahasiswa di Polibatam?',
    ),
  ];

  static CampusInfoModule? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  static List<CampusInfoModule> byCategory(CampusInfoCategory cat) =>
      all.where((m) => m.category == cat).toList();

  static String categoryLabel(CampusInfoCategory cat) => switch (cat) {
        CampusInfoCategory.akademik => 'Informasi Akademik',
        CampusInfoCategory.kampus => 'Informasi Kampus',
        CampusInfoCategory.bantuan => 'Bantuan',
      };
}
