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
await page.waitForTimeout(3500);

await page.mouse.click(146, 810);
await page.waitForTimeout(2000);

// Fokus input & kirim pertanyaan
await page.mouse.click(180, 790);
await page.waitForTimeout(600);
await page.keyboard.type('Apa saja jenis beasiswa di Polibatam?', { delay: 20 });
await page.waitForTimeout(400);
await page.mouse.click(355, 790);
await page.waitForTimeout(22000);
await page.screenshot({ path: join(OUT, '03-chatbot-jawaban-ai.png'), type: 'png' });
console.log('done');
await browser.close();
