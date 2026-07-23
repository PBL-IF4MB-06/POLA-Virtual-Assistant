/// Titik lokasi & media kampus Polibatam untuk jawaban kaya (gambar + rute).
class CampusPoi {
  const CampusPoi({
    required this.id,
    required this.name,
    required this.aliases,
    required this.lat,
    required this.lng,
    required this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final List<String> aliases;
  final double lat;
  final double lng;
  final String description;
  final String? imageUrl;

  String get mapsPlaceUrl =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

  String get osmStaticMapUrl =>
      'https://staticmap.openstreetmap.de/staticmap.php'
      '?center=$lat,$lng&zoom=17&size=640x360&maptype=mapnik'
      '&markers=$lat,$lng,lightblue1';
}

class CampusRouteCard {
  const CampusRouteCard({
    required this.title,
    required this.fromLabel,
    required this.toLabel,
    required this.mapsUrl,
    this.summary = '',
  });

  final String title;
  final String fromLabel;
  final String toLabel;
  final String mapsUrl;
  final String summary;
}

class CampusMediaHit {
  const CampusMediaHit({
    this.images = const [],
    this.routes = const [],
    this.hintText = '',
  });

  final List<({String url, String label})> images;
  final List<CampusRouteCard> routes;
  final String hintText;

  bool get isEmpty => images.isEmpty && routes.isEmpty;
}

/// Deteksi intent lokasi/gambar/rute dari pertanyaan mahasiswa.
abstract final class CampusMedia {
  /// Koordinat sekitar kawasan Polibatam, Batam (perkiraan area kampus).
  static const gate = CampusPoi(
    id: 'gate',
    name: 'Pintu Gerbang Polibatam',
    aliases: ['gerbang', 'pintu masuk', 'lobby', 'depan kampus'],
    lat: 1.0458,
    lng: 104.0395,
    description: 'Arah masuk utama kampus Politeknik Negeri Batam.',
  );

  static const gedungTi = CampusPoi(
    id: 'gedung_ti',
    name: 'Gedung Teknik Informatika',
    aliases: [
      'gedung ti',
      'gedung informatika',
      'teknik informatika',
      'lab ti',
      'jurusan ti',
    ],
    lat: 1.0464,
    lng: 104.0402,
    description: 'Area gedung/jurusan Teknik Informatika.',
  );

  static const perpustakaan = CampusPoi(
    id: 'perpustakaan',
    name: 'Perpustakaan',
    aliases: ['perpustakaan', 'library', 'pustaka'],
    lat: 1.0461,
    lng: 104.0391,
    description: 'Perpustakaan kampus Polibatam.',
  );

  static const aula = CampusPoi(
    id: 'aula',
    name: 'Aula Polibatam',
    aliases: ['aula', 'auditorium', 'hall'],
    lat: 1.0455,
    lng: 104.0400,
    description: 'Aula / ruang acara kampus.',
  );

  static const parkir = CampusPoi(
    id: 'parkir',
    name: 'Area Parkir',
    aliases: ['parkir', 'parking', 'tempat parkir'],
    lat: 1.0452,
    lng: 104.0388,
    description: 'Area parkir kendaraan mahasiswa/dosen.',
  );

  static const masjid = CampusPoi(
    id: 'masjid',
    name: 'Masjid Kampus',
    aliases: ['masjid', 'musholla', 'mushola', 'shalat'],
    lat: 1.0468,
    lng: 104.0398,
    description: 'Fasilitas ibadah di area kampus.',
  );

  static const kantin = CampusPoi(
    id: 'kantin',
    name: 'Kantin / Food Court',
    aliases: ['kantin', 'food court', 'makan', 'cafe'],
    lat: 1.0459,
    lng: 104.0406,
    description: 'Area kantin mahasiswa.',
  );

  static const allPois = <CampusPoi>[
    gate,
    gedungTi,
    perpustakaan,
    aula,
    parkir,
    masjid,
    kantin,
  ];

  static String directionsUrl(CampusPoi from, CampusPoi to) {
    return 'https://www.google.com/maps/dir/?api=1'
        '&origin=${from.lat},${from.lng}'
        '&destination=${to.lat},${to.lng}'
        '&travelmode=walking';
  }

  static CampusPoi? matchPoi(String text) {
    final q = text.toLowerCase();
    CampusPoi? best;
    var bestScore = 0;
    for (final poi in allPois) {
      var score = 0;
      if (q.contains(poi.name.toLowerCase())) score += 5;
      for (final a in poi.aliases) {
        if (q.contains(a)) score += 3;
      }
      if (score > bestScore) {
        bestScore = score;
        best = poi;
      }
    }
    return bestScore > 0 ? best : null;
  }

  static List<CampusPoi> matchPois(String text, {int limit = 2}) {
    final q = text.toLowerCase();
    final scored = <({CampusPoi poi, int score})>[];
    for (final poi in allPois) {
      var score = 0;
      if (q.contains(poi.name.toLowerCase())) score += 5;
      for (final a in poi.aliases) {
        if (q.contains(a)) score += 3;
      }
      if (score > 0) scored.add((poi: poi, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((e) => e.poi).toList();
  }

  static bool wantsImage(String text) {
    final q = text.toLowerCase();
    return RegExp(
      r'\b(gambar|foto|photo|image|visual|peta|map|tampak|lihat bentuk)\b',
    ).hasMatch(q);
  }

  static bool wantsRoute(String text) {
    final q = text.toLowerCase();
    return RegExp(
      r'\b(rute|arah|jalan|navigasi|menuju|ke gedung|lokasi|di mana|dimana|cara ke|petunjuk)\b',
    ).hasMatch(q);
  }

  /// Enrichment lokal: gambar peta + kartu rute berdasarkan pertanyaan.
  static CampusMediaHit enrich(String question) {
    final q = question.trim();
    if (q.isEmpty) return const CampusMediaHit();

    final imageIntent = wantsImage(q);
    final routeIntent = wantsRoute(q);
    if (!imageIntent && !routeIntent) {
      // Tetap bantu jika menyebut POI jelas (lokasi).
      final poiOnly = matchPoi(q);
      if (poiOnly == null) return const CampusMediaHit();
    }

    final pois = matchPois(q, limit: 2);
    final images = <({String url, String label})>[];
    final routes = <CampusRouteCard>[];

    if (pois.isEmpty && (imageIntent || routeIntent)) {
      // Default: gerbang kampus
      images.add((url: gate.osmStaticMapUrl, label: 'Peta ${gate.name}'));
      routes.add(
        CampusRouteCard(
          title: 'Buka peta kampus',
          fromLabel: 'Posisi Anda',
          toLabel: gate.name,
          mapsUrl: gate.mapsPlaceUrl,
          summary: gate.description,
        ),
      );
      return CampusMediaHit(
        images: images,
        routes: routes,
        hintText: 'Menampilkan peta gerbang utama Polibatam.',
      );
    }

    for (final poi in pois) {
      if (imageIntent || routeIntent || true) {
        images.add((url: poi.osmStaticMapUrl, label: 'Peta ${poi.name}'));
      }
    }

    if (routeIntent || pois.isNotEmpty) {
      if (pois.length >= 2) {
        final from = pois[1];
        final to = pois[0];
        routes.add(
          CampusRouteCard(
            title: 'Rute ${from.name} → ${to.name}',
            fromLabel: from.name,
            toLabel: to.name,
            mapsUrl: directionsUrl(from, to),
            summary: 'Perkiraan rute pejalan kaki di area kampus.',
          ),
        );
      } else if (pois.isNotEmpty) {
        final to = pois.first;
        routes.add(
          CampusRouteCard(
            title: 'Arah ke ${to.name}',
            fromLabel: 'Gerbang / titik masuk',
            toLabel: to.name,
            mapsUrl: directionsUrl(gate, to),
            summary: to.description,
          ),
        );
        routes.add(
          CampusRouteCard(
            title: 'Buka di Google Maps',
            fromLabel: 'Lokasi',
            toLabel: to.name,
            mapsUrl: to.mapsPlaceUrl,
            summary: 'Pin lokasi ${to.name}',
          ),
        );
      }
    }

    return CampusMediaHit(images: images, routes: routes);
  }
}
