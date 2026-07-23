import { chromium } from 'playwright';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const html = join(__dir, 'DRAFT_PROPOSAL_TA_POLA.html');
const pdf = join(__dir, 'DRAFT_PROPOSAL_TA_POLA.pdf');

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(`file:///${html.replace(/\\/g, '/')}`, { waitUntil: 'networkidle' });
await page.pdf({
  path: pdf,
  format: 'A4',
  printBackground: true,
  margin: { top: '20mm', bottom: '20mm', left: '20mm', right: '20mm' },
});
await browser.close();
console.log('PDF:', pdf);
