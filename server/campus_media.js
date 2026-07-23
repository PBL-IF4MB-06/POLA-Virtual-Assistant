/**
 * Enrich jawaban AI dengan gambar peta + rute Google Maps untuk lokasi kampus.
 */
const POIS = [
  {
    id: 'gate',
    name: 'Pintu Gerbang Polibatam',
    aliases: ['gerbang', 'pintu masuk', 'lobby', 'depan kampus'],
    lat: 1.0458,
    lng: 104.0395,
    description: 'Arah masuk utama kampus Politeknik Negeri Batam.',
  },
  {
    id: 'gedung_ti',
    name: 'Gedung Teknik Informatika',
    aliases: ['gedung ti', 'gedung informatika', 'teknik informatika', 'lab ti', 'jurusan ti'],
    lat: 1.0464,
    lng: 104.0402,
    description: 'Area gedung/jurusan Teknik Informatika.',
  },
  {
    id: 'perpustakaan',
    name: 'Perpustakaan',
    aliases: ['perpustakaan', 'library', 'pustaka'],
    lat: 1.0461,
    lng: 104.0391,
    description: 'Perpustakaan kampus Polibatam.',
  },
  {
    id: 'aula',
    name: 'Aula Polibatam',
    aliases: ['aula', 'auditorium', 'hall'],
    lat: 1.0455,
    lng: 104.04,
    description: 'Aula / ruang acara kampus.',
  },
  {
    id: 'parkir',
    name: 'Area Parkir',
    aliases: ['parkir', 'parking', 'tempat parkir'],
    lat: 1.0452,
    lng: 104.0388,
    description: 'Area parkir kendaraan mahasiswa/dosen.',
  },
  {
    id: 'masjid',
    name: 'Masjid Kampus',
    aliases: ['masjid', 'musholla', 'mushola', 'shalat'],
    lat: 1.0468,
    lng: 104.0398,
    description: 'Fasilitas ibadah di area kampus.',
  },
  {
    id: 'kantin',
    name: 'Kantin / Food Court',
    aliases: ['kantin', 'food court', 'makan', 'cafe'],
    lat: 1.0459,
    lng: 104.0406,
    description: 'Area kantin mahasiswa.',
  },
];

function scorePoi(q, poi) {
  let score = 0;
  const name = String(poi.name || '').toLowerCase();
  if (name && q.includes(name)) score += 5;
  for (const a of poi.aliases || []) {
    if (q.includes(String(a).toLowerCase())) score += 3;
  }
  return score;
}

function matchPois(text, limit = 2) {
  const q = String(text || '').toLowerCase();
  return POIS.map((poi) => ({ poi, score: scorePoi(q, poi) }))
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map((x) => x.poi);
}

function wantsImage(q) {
  return /\b(gambar|foto|photo|image|visual|peta|map|tampak|lihat bentuk)\b/i.test(q);
}

function wantsRoute(q) {
  return /\b(rute|arah|jalan|navigasi|menuju|ke gedung|lokasi|di mana|dimana|cara ke|petunjuk)\b/i.test(
    q,
  );
}

function osmStatic(lat, lng) {
  return (
    `https://staticmap.openstreetmap.de/staticmap.php` +
    `?center=${lat},${lng}&zoom=17&size=640x360&maptype=mapnik` +
    `&markers=${lat},${lng},lightblue1`
  );
}

function mapsPlace(lat, lng) {
  return `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`;
}

function mapsDir(from, to) {
  return (
    `https://www.google.com/maps/dir/?api=1` +
    `&origin=${from.lat},${from.lng}` +
    `&destination=${to.lat},${to.lng}` +
    `&travelmode=walking`
  );
}

/**
 * @param {string} question pertanyaan user asli
 * @returns {{ images: Array<{url:string,label:string}>, routes: Array<object> }}
 */
export function enrichCampusMedia(question) {
  const q = String(question || '').trim();
  const images = [];
  const routes = [];
  if (!q) return { images, routes };

  const img = wantsImage(q);
  const route = wantsRoute(q);
  let pois = matchPois(q, 2);

  if (!img && !route && pois.length === 0) {
    return { images, routes };
  }

  const gate = POIS[0];
  if (pois.length === 0) {
    pois = [gate];
  }

  for (const poi of pois) {
    images.push({
      url: osmStatic(poi.lat, poi.lng),
      label: `Peta ${poi.name}`,
    });
  }

  if (route || pois.length > 0) {
    if (pois.length >= 2) {
      const to = pois[0];
      const from = pois[1];
      routes.push({
        title: `Rute ${from.name} → ${to.name}`,
        fromLabel: from.name,
        toLabel: to.name,
        mapsUrl: mapsDir(from, to),
        summary: 'Perkiraan rute pejalan kaki di area kampus.',
      });
    } else {
      const to = pois[0];
      routes.push({
        title: `Arah ke ${to.name}`,
        fromLabel: 'Gerbang / titik masuk',
        toLabel: to.name,
        mapsUrl: mapsDir(gate, to),
        summary: to.description || '',
      });
      routes.push({
        title: 'Buka di Google Maps',
        fromLabel: 'Lokasi',
        toLabel: to.name,
        mapsUrl: mapsPlace(to.lat, to.lng),
        summary: `Pin lokasi ${to.name}`,
      });
    }
  }

  return { images, routes };
}
