/** Fix screenshot login, pengaturan, chatbot jawaban, landing */
import { chromium } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const root = join(__dir, '..');
const OUT = join(root, 'docs', 'bab4', 'screenshots');
const BASE = `http://127.0.0.1:8080`;

const browser = await chromium.launch({ headless: true });
const page = await (await browser.newContext({
  viewport: { width: 390, height: 844 },
  deviceScaleFactor: 3,
  isMobile: true,
})).newPage();

async function shot(name, ms = 2000) {
  await page.waitForTimeout(ms);
  await page.screenshot({ path: join(OUT, name), type: 'png', animations: 'disabled' });
  console.log('OK:', name);
}

async function tapNav(i) {
  await page.mouse.click(Math.round((390 / 4) * (i + 0.5)), 810);
  await page.waitForTimeout(1500);
}

await page.goto(`${BASE}/app/`, { waitUntil: 'networkidle', timeout: 60000 });
await page.evaluate(() => localStorage.setItem('flutter.pola_onboarding_done_v8', 'true'));
await page.reload({ waitUntil: 'networkidle' });
await page.waitForTimeout(3000);

// Chatbot + jawaban via chip Beasiswa
await tapNav(1);
await page.mouse.click(280, 455);
await page.waitForTimeout(20000);
await shot('03-chatbot-jawaban-ai.png', 1500);

// Profil -> Login
await tapNav(3);
await page.mouse.click(195, 555);
await page.waitForTimeout(2500);
await shot('07-login-register.png', 1000);
await page.goBack().catch(() => {});
await page.waitForTimeout(1500);

// Profil -> Pengaturan
await page.mouse.click(195, 755);
await page.waitForTimeout(2500);
await shot('08-pengaturan.png', 1000);

// Landing
await page.goto(`${BASE}/`, { waitUntil: 'domcontentloaded', timeout: 60000 });
await page.waitForTimeout(2500);
await shot('09-landing-website.png', 500);

await browser.close();
