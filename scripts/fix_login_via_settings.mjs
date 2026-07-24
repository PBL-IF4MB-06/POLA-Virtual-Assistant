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

// Profil -> Pengaturan -> Buat akun baru
await page.mouse.click(341, 810);
await page.waitForTimeout(2000);
await page.mouse.click(195, 748);
await page.waitForTimeout(2500);
await page.screenshot({ path: join(OUT, '08-pengaturan.png'), type: 'png' });

// Buat akun baru row
await page.mouse.click(195, 620);
await page.waitForTimeout(3000);
await page.screenshot({ path: join(OUT, '07-login-register.png'), type: 'png' });

await browser.close();
console.log('done');
