/**
 * Ambil screenshot lengkap untuk BAB IV (resolusi tinggi, tidak blur).
 * Jalankan setelah: flutter run -d web-server --web-port=8080
 *   node scripts/capture_bab4_screenshots.mjs [port]
 */
import { chromium } from 'playwright';
import { mkdirSync, copyFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const root = join(__dir, '..');
const OUT_BAB4 = join(root, 'docs', 'bab4', 'screenshots');
const OUT_SS = join(root, 'screenshots');
const PORT = process.argv[2] || '8080';
const BASE = `http://127.0.0.1:${PORT}`;

mkdirSync(OUT_BAB4, { recursive: true });
mkdirSync(OUT_SS, { recursive: true });

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 390, height: 844 },
  deviceScaleFactor: 3,
  isMobile: true,
  hasTouch: true,
  locale: 'id-ID',
});
const page = await context.newPage();

async function shot(bab4Name, ssName, waitMs = 2500) {
  await page.waitForTimeout(waitMs);
  const p1 = join(OUT_BAB4, bab4Name);
  const p2 = join(OUT_SS, ssName);
  await page.screenshot({ path: p1, type: 'png', animations: 'disabled' });
  copyFileSync(p1, p2);
  console.log('OK:', bab4Name, '->', ssName);
}

async function tapNav(index) {
  const x = Math.round((390 / 4) * (index + 0.5));
  await page.mouse.click(x, 810);
  await page.waitForTimeout(1500);
}

console.log(`Base URL: ${BASE}/app/`);

// Splash & onboarding (reset onboarding flag)
await page.goto(`${BASE}/app/`, { waitUntil: 'networkidle', timeout: 90000 });
await page.evaluate(() => localStorage.removeItem('flutter.pola_onboarding_done_v8'));
await page.reload({ waitUntil: 'networkidle', timeout: 90000 });
await page.waitForTimeout(2000);
await shot('00-splash.png', 'SS-01_splash.png', 1200);

// Onboarding slide 1
await page.waitForTimeout(3500);
await shot('00-onboarding.png', 'SS-02_onboarding.png', 800);
await page.evaluate(() => localStorage.setItem('flutter.pola_onboarding_done_v8', 'true'));
await page.reload({ waitUntil: 'networkidle', timeout: 90000 });
await page.waitForTimeout(3500);

await shot('01-beranda.png', 'SS-03_beranda.png', 1500);

await tapNav(1);
await shot('02-chatbot-kosong.png', 'SS-04_chatbot_kosong.png', 2000);

await page.mouse.click(195, 765);
await page.waitForTimeout(600);
await page.keyboard.type('Apa saja jenis beasiswa di Polibatam?', { delay: 20 });
await page.waitForTimeout(400);
await page.mouse.click(340, 765);
await page.waitForTimeout(18000);
await shot('03-chatbot-jawaban-ai.png', 'SS-05_chatbot_jawaban.png', 2000);

await tapNav(2);
await shot('04-kampus-hub.png', 'SS-08_campus_hub.png', 2000);
await page.mouse.click(290, 420);
await shot('05-kampus-beasiswa.png', 'SS-09_detail_beasiswa.png', 2500);
await page.goBack().catch(() => {});
await page.waitForTimeout(1200);

// Pencarian kampus
await page.mouse.click(360, 60);
await page.waitForTimeout(2000);
await shot('10-pencarian-kampus.png', 'SS-10_pencarian_kampus.png', 1500);
await page.goBack().catch(() => {});
await page.waitForTimeout(1000);

await tapNav(0);
await page.mouse.click(195, 680);
await page.waitForTimeout(1500);
await shot('11-pengumuman-beranda.png', 'SS-11_pengumuman.png', 1500);

await tapNav(3);
await shot('06-profil.png', 'SS-13_profil.png', 2000);

await page.mouse.wheel(0, 80);
await page.waitForTimeout(400);
await page.mouse.click(195, 560);
await page.waitForTimeout(2000);
await shot('07-login-register.png', 'SS-17_login.png', 1500);
await page.goBack().catch(() => {});
await page.waitForTimeout(800);

await page.mouse.click(195, 720);
await shot('08-pengaturan.png', 'SS-18_pengaturan.png', 2000);
await page.goBack().catch(() => {});

// Dark mode via settings if visible
await page.mouse.click(195, 720);
await page.waitForTimeout(1000);
await page.mouse.click(330, 180);
await page.waitForTimeout(1200);
await shot('12-tema-gelap.png', 'SS-16_tema_gelap.png', 1500);
await page.goBack().catch(() => {});

await browser.close();
console.log('\nSelesai. Screenshot di:', OUT_BAB4, 'dan', OUT_SS);
