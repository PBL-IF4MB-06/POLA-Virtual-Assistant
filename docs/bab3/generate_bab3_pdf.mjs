import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import { createRequire } from 'module';

const require = createRequire(pathToFileURL(join(dirname(fileURLToPath(import.meta.url)), '..', '..', 'scripts', 'package.json')));
const { chromium } = require('playwright');

const __dir = dirname(fileURLToPath(import.meta.url));
const md = readFileSync(join(__dir, 'BAB_III_PERANCANGAN_SISTEM.md'), 'utf8');

let body = md
  .replace(/^# BAB III[\s\S]*?---\n\n/m, '')
  .replace(/^## (.*)$/gm, '<h2>$1</h2>')
  .replace(/^### (.*)$/gm, '<h3>$1</h3>')
  .replace(/^#### (.*)$/gm, '<h4>$1</h4>')
  .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
  .replace(/\*(.*?)\*/g, '<em>$1</em>')
  .replace(/!\[(.*?)\]\((.*?)\)/g, '<figure><img src="$2" alt="$1" style="max-width:100%;border:1px solid #ccc;border-radius:8px"/><figcaption>$1</figcaption></figure>')
  .replace(/^---$/gm, '<hr/>')
  .replace(/^\|(.+)\|$/gm, (line) => {
    if (line.includes('---')) return '';
    const cells = line.split('|').filter(Boolean).map((c) => c.trim());
    return '<tr>' + cells.map((c) => `<td>${c}</td>`).join('') + '</tr>';
  })
  .replace(/(<tr>[\s\S]*?<\/tr>\n?)+/g, (m) =>
    `<table border="1" cellpadding="6" cellspacing="0" style="width:100%;border-collapse:collapse;font-size:10pt;margin:8px 0">${m}</table>`,
  )
  .replace(/^(\d+\. .*)$/gm, '<li>$1</li>')
  .replace(/^- (.*)$/gm, '<li>$1</li>')
  .replace(/<br>/g, '<br/>')
  .replace(/\n\n/g, '</p><p>');

const html = `<!DOCTYPE html><html lang="id"><head><meta charset="UTF-8"/>
<title>BAB III Perancangan Sistem POLA</title>
<style>
@page{margin:2cm;size:A4}
body{font-family:"Times New Roman",Times,serif;font-size:11pt;line-height:1.45;color:#111;max-width:17cm;margin:0 auto;padding:1cm}
h2{font-size:13pt;margin-top:14px;border-bottom:1px solid #333}
h3{font-size:12pt;margin-top:10px}
h4{font-size:11pt;margin-top:8px;font-style:italic}
table{font-size:9.5pt}
figure{text-align:center;margin:12px 0;page-break-inside:avoid}
figcaption{font-size:10pt;font-style:italic;margin-top:4px}
hr{border:none;border-top:1px solid #ccc;margin:12px 0}
p{text-align:justify;margin:6px 0}
.cover{text-align:center;margin-bottom:16px}
</style></head><body>
<div class="cover">
<h1>BAB III<br/>PERANCANGAN SISTEM</h1>
<p><strong>Implementasi Chatbot AI pada Aplikasi POLA Berbasis Mobile</strong><br/>
Kode PBL: IF-4MB-06 | Teknik Informatika | Politeknik Negeri Batam</p>
</div>
<p>${body}</p>
</body></html>`;

writeFileSync(join(__dir, 'BAB_III_PERANCANGAN_SISTEM.html'), html);

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(`file:///${join(__dir, 'BAB_III_PERANCANGAN_SISTEM.html').replace(/\\/g, '/')}`, {
  waitUntil: 'networkidle',
});
await page.pdf({
  path: join(__dir, 'BAB_III_PERANCANGAN_SISTEM.pdf'),
  format: 'A4',
  printBackground: true,
  margin: { top: '18mm', bottom: '18mm', left: '18mm', right: '18mm' },
});
await browser.close();
console.log('PDF selesai:', join(__dir, 'BAB_III_PERANCANGAN_SISTEM.pdf'));
