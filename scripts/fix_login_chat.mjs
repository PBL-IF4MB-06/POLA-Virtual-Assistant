import { chromium } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const OUT = join(__dir, '..', 'docs', 'bab4', 'screenshots');

const browser = await chromium.launch({ headless: true });
const page = await (await browser.newContext({
  viewport: { width: 390, height: 844 },
  deviceScaleFactor: 3,
  isMobile: true,
})).newPage();

await page.goto('http://127.0.0.1:8080/app/', { waitUntil: 'networkidle' });
await page.evaluate(() => localStorage.setItem('flutter.pola_onboarding_done_v8', 'true'));
await page.reload({ waitUntil: 'networkidle' });
await page.waitForTimeout(3000);

await page.mouse.click(146, 810);
await page.waitForTimeout(1500);

// Tap chip Beasiswa
await page.mouse.click(280, 455);
await page.waitForTimeout(25000);
await page.screenshot({ path: join(OUT, '03-chatbot-jawaban-ai.png'), type: 'png' });
console.log('chatbot done');

// Profil tab
await page.mouse.click(341, 810);
await page.waitForTimeout(2000);

// Login / Daftar - first menu card center
await page.mouse.click(195, 500);
await page.waitForTimeout(3000);
await page.screenshot({ path: join(OUT, '07-login-register.png'), type: 'png' });
console.log('login done');

await browser.close();
