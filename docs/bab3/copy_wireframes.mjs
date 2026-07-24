/**
 * Salin screenshot aplikasi POLA untuk wireframe BAB III (resolusi tinggi).
 * Menggunakan screenshot yang sudah ada dari docs/bab4 dan folder screenshots/.
 */
import { copyFileSync, mkdirSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const root = join(__dir, '..', '..');
const OUT = join(__dir, 'wireframes');
mkdirSync(OUT, { recursive: true });

const map = [
  ['docs/bab4/screenshots/01-beranda.png', '07-wireframe-beranda.png'],
  ['docs/bab4/screenshots/02-chatbot-kosong.png', '08-wireframe-chatbot.png'],
  ['docs/bab4/screenshots/03-chatbot-jawaban-ai.png', '09-wireframe-chatbot-jawaban.png'],
  ['docs/bab4/screenshots/04-kampus-hub.png', '10-wireframe-kampus-hub.png'],
  ['docs/bab4/screenshots/05-kampus-beasiswa.png', '11-wireframe-detail-kampus.png'],
  ['docs/bab4/screenshots/06-profil.png', '12-wireframe-profil.png'],
  ['docs/bab4/screenshots/07-login-register.png', '13-wireframe-login-register.png'],
  ['docs/bab4/screenshots/08-pengaturan.png', '14-wireframe-pengaturan.png'],
  ['screenshots/SS-01_splash.png', '15-wireframe-splash.png'],
  ['screenshots/SS-02_onboarding.png', '16-wireframe-onboarding.png'],
];

for (const [src, dest] of map) {
  const from = join(root, src);
  const to = join(OUT, dest);
  if (!existsSync(from)) {
    console.warn('SKIP (tidak ada):', src);
    continue;
  }
  copyFileSync(from, to);
  console.log('OK:', dest);
}

console.log('\nWireframe screenshots di:', OUT);
