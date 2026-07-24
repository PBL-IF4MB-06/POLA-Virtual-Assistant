import { chromium } from 'playwright';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const md = readFileSync(join(__dir, 'BAB_IV_IMPLEMENTASI_PENGUJIAN.md'), 'utf8');

// Simple MD to HTML for PDF (headings, tables as pre, images)
let body = md
  .replace(/^# BAB IV[\s\S]*?---\n\n/m, '')
  .replace(/^## (.*)$/gm, '<h2>$1</h2>')
  .replace(/^### (.*)$/gm, '<h3>$1</h3>')
  .replace(/^#### (.*)$/gm, '<h4>$1</h4>')
  .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
  .replace(/\*(.*?)\*/g, '<em>$1</em>')
  .replace(/!\[(.*?)\]\((.*?)\)/g, '<figure><img src="$2" alt="$1" style="max-width:280px;border:1px solid #ccc;border-radius:8px"/><figcaption>$1</figcaption></figure>')
  .replace(/^---$/gm, '<hr/>')
  .replace(/```[\s\S]*?```/g, (m) => `<pre>${m.replace(/```/g, '').trim()}</pre>`)
  .replace(/^\|(.+)\|$/gm, (line) => {
    if (line.includes('---')) return '';
    const cells = line.split('|').filter(Boolean).map(c => c.trim());
    return '<tr>' + cells.map(c => `<td>${c}</td>`).join('') + '</tr>';
  })
  .replace(/(<tr>[\s\S]*?<\/tr>\n?)+/g, (m) => `<table border="1" cellpadding="6" cellspacing="0" style="width:100%;border-collapse:collapse;font-size:10pt;margin:8px 0">${m}</table>`)
  .replace(/^(\d+\. .*)$/gm, '<li>$1</li>')
  .replace(/^- (.*)$/gm, '<li>$1</li>')
  .replace(/\n\n/g, '</p><p>');

const html = `<!DOCTYPE html><html lang="id"><head><meta charset="UTF-8"/>
<title>BAB IV Implementasi dan Pengujian POLA</title>
<style>
@page{margin:2cm;size:A4}
body{font-family:"Times New Roman",Times,serif;font-size:11pt;line-height:1.45;color:#111;max-width:17cm;margin:0 auto;padding:1cm}
h1{font-size:16pt;text-align:center;text-transform:uppercase}
h2{font-size:13pt;margin-top:14px;border-bottom:1px solid #333}
h3{font-size:12pt;margin-top:10px}
h4{font-size:11pt;margin-top:8px;font-style:italic}
table{font-size:9.5pt}
pre{background:#f5f5f5;padding:8px;font-size:9pt;overflow-x:auto;white-space:pre-wrap}
figure{text-align:center;margin:12px 0;page-break-inside:avoid}
figcaption{font-size:10pt;font-style:italic;margin-top:4px}
hr{border:none;border-top:1px solid #ccc;margin:12px 0}
p{text-align:justify;margin:6px 0}
.cover{text-align:center;margin-bottom:16px}
</style></head><body>
<div class="cover">
<h1>BAB IV<br/>IMPLEMENTASI DAN PENGUJIAN</h1>
<p><strong>Implementasi Chatbot AI pada Aplikasi POLA Berbasis Mobile</strong><br/>
Kode PBL: IF-4MB-06 | Teknik Informatika | Politeknik Negeri Batam<br/>
Muhammad Nabil (3312411007) & Bindhu Owen Batami Hutagalung (3312411017)</p>
</div>
<p>${body}</p>
</body></html>`;

writeFileSync(join(__dir, 'BAB_IV_IMPLEMENTASI_PENGUJIAN.html'), html);

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(`file:///${join(__dir, 'BAB_IV_IMPLEMENTASI_PENGUJIAN.html').replace(/\\/g, '/')}`, { waitUntil: 'networkidle' });
await page.pdf({
  path: join(__dir, 'BAB_IV_IMPLEMENTASI_PENGUJIAN.pdf'),
  format: 'A4',
  printBackground: true,
  margin: { top: '18mm', bottom: '18mm', left: '18mm', right: '18mm' },
});
await browser.close();
console.log('PDF selesai');
