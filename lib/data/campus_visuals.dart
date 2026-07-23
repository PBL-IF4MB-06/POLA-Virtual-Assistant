/// Visual kampus untuk UI premium (foto stock berkualitas tinggi).
/// Diganti mudah jika nanti ada foto resmi Polibatam.
abstract final class CampusVisuals {
  static const heroCampus =
      'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=1400&q=80';
  static const courtyard =
      'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?auto=format&fit=crop&w=1000&q=80';
  static const library =
      'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1000&q=80';
  static const lecture =
      'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?auto=format&fit=crop&w=1000&q=80';
  static const pathway =
      'https://images.unsplash.com/photo-1498243691581-b145c3f54a5a?auto=format&fit=crop&w=1000&q=80';

  static const showcase = <({String url, String title, String caption})>[
    (
      url: courtyard,
      title: 'Suasana Kampus',
      caption: 'Area akademik Polibatam',
    ),
    (
      url: library,
      title: 'Belajar & Riset',
      caption: 'Fasilitas pendukung mahasiswa',
    ),
    (
      url: lecture,
      title: 'Civitas Akademika',
      caption: 'Mahasiswa & dosen berkolaborasi',
    ),
    (
      url: pathway,
      title: 'Lingkungan Kampus',
      caption: 'Ruang hijau & jalur pejalan',
    ),
  ];
}
