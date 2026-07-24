import 'package:flutter/material.dart';

enum AnnouncementType { akademik, beasiswa, lomba, seminar }

class CampusAnnouncement {
  const CampusAnnouncement({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.date,
    required this.type,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final DateTime date;
  final AnnouncementType type;
}

class CampusAnnouncements {
  static final all = <CampusAnnouncement>[
    CampusAnnouncement(
      id: 'a1',
      title: 'Pembukaan Periode KRS Semester Genap',
      summary: 'KRS online dibuka 10–14 Februari melalui SIA.',
      body:
          'Mahasiswa diwajibkan berkonsultasi dengan dosen wali sebelum mengisi KRS. '
          'Pastikan tidak ada tunggakan administrasi. Panduan lengkap tersedia di portal akademik.',
      date: DateTime(2026, 2, 3),
      type: AnnouncementType.akademik,
    ),
    CampusAnnouncement(
      id: 'a2',
      title: 'Jadwal UTS Semester Genap 2025/2026',
      summary: 'UTS dilaksanakan 17–28 Maret 2026.',
      body:
          'Jadwal per mata kuliah dapat diakses melalui SIA. Mahasiswa wajib membawa kartu ujian '
          'dan mematuhi aturan kejujuran akademik.',
      date: DateTime(2026, 2, 28),
      type: AnnouncementType.akademik,
    ),
    CampusAnnouncement(
      id: 'a3',
      title: 'Beasiswa Prestasi Polibatam 2026',
      summary: 'Pendaftaran dibuka hingga 31 Maret 2026.',
      body:
          'Syarat: IPK minimal 3.50, aktif organisasi, dan surat rekomendasi dosen wali. '
          'Lampirkan transkrip dan bukti prestasi. Pengumuman seleksi via email kampus.',
      date: DateTime(2026, 3, 1),
      type: AnnouncementType.beasiswa,
    ),
    CampusAnnouncement(
      id: 'a4',
      title: 'Beasiswa KIP-Kuliah Tahap II',
      summary: 'Informasi registrasi ulang penerima KIP.',
      body:
          'Penerima beasiswa KIP wajib melengkapi dokumen verifikasi di bagian kemahasiswaan '
          'sesuai jadwal yang ditentukan.',
      date: DateTime(2026, 2, 15),
      type: AnnouncementType.beasiswa,
    ),
    CampusAnnouncement(
      id: 'a5',
      title: 'Lomba Inovasi Digital Mahasiswa',
      summary: 'Tim terbaik dari tiap prodi diundang mengikuti babak kampus.',
      body:
          'Tema: solusi digital untuk industri Batam. Pendaftaran melalui BEM. '
          'Hadiah total Rp15 juta dan sertifikat.',
      date: DateTime(2026, 3, 5),
      type: AnnouncementType.lomba,
    ),
    CampusAnnouncement(
      id: 'a6',
      title: 'Seminar Karier & Magang Industri',
      summary: 'Rabu, 12 Maret 2026 — Aula Polibatam.',
      body:
          'Menghadirkan perusahaan mitra dari sektor manufaktur dan IT. '
          'Daftar via link yang tersedia di media sosial resmi kampus.',
      date: DateTime(2026, 3, 8),
      type: AnnouncementType.seminar,
    ),
    CampusAnnouncement(
      id: 'a7',
      title: 'Libur Hari Raya Idul Fitri 1447 H',
      summary: 'Kampus libur sesuai kalender akademik.',
      body:
          'Perkuliahan diliburkan sesuai keputusan direktur. '
          'Kegiatan administrasi kembali normal setelah libur.',
      date: DateTime(2026, 2, 20),
      type: AnnouncementType.akademik,
    ),
  ];

  static String typeLabel(AnnouncementType t) => switch (t) {
        AnnouncementType.akademik => 'Akademik',
        AnnouncementType.beasiswa => 'Beasiswa',
        AnnouncementType.lomba => 'Lomba',
        AnnouncementType.seminar => 'Seminar',
      };

  static IconData typeIcon(AnnouncementType t) => switch (t) {
        AnnouncementType.akademik => Icons.school_outlined,
        AnnouncementType.beasiswa => Icons.volunteer_activism_outlined,
        AnnouncementType.lomba => Icons.emoji_events_outlined,
        AnnouncementType.seminar => Icons.record_voice_over_outlined,
      };

  static List<CampusAnnouncement> byType(AnnouncementType? type) {
    if (type == null) return List.unmodifiable(all);
    return all.where((a) => a.type == type).toList();
  }

  static CampusAnnouncement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
