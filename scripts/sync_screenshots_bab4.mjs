/**
 * Salin & sinkronkan screenshot ke folder screenshots/ (SS-XX) untuk BAB IV.
 * Gunakan docs/bab4/screenshots sebagai sumber utama.
 */
import { copyFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const root = join(__dir, '..');
const bab4 = join(root, 'docs', 'bab4', 'screenshots');
const out = join(root, 'screenshots');
mkdirSync(out, { recursive: true });

const map = [
  ['01-beranda.png', 'SS-03_beranda.png'],
  ['02-chatbot-kosong.png', 'SS-04_chatbot_kosong.png'],
  ['03-chatbot-jawaban-ai.png', 'SS-05_chatbot_jawaban.png'],
  ['04-kampus-hub.png', 'SS-08_campus_hub.png'],
  ['05-kampus-beasiswa.png', 'SS-09_detail_beasiswa.png'],
  ['06-profil.png', 'SS-13_profil.png'],
  ['07-login-register.png', 'SS-17_login.png'],
  ['08-pengaturan.png', 'SS-18_pengaturan.png'],
];

for (const [src, dest] of map) {
  const from = join(bab4, src);
  const to = join(out, dest);
  if (existsSync(from)) {
    copyFileSync(from, to);
    console.log('OK:', dest);
  } else {
    console.warn('SKIP:', src);
  }
}

// File yang sudah ada di screenshots/ (onboarding, splash, dll.) tetap dipakai
console.log('\nSelesai. Folder:', out);
