/**
 * Render diagram PlantUML BAB III ke PNG resolusi tinggi via Kroki.io
 * Usage: node docs/bab3/generate_diagrams.mjs
 */
import { readFileSync, mkdirSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dir = dirname(fileURLToPath(import.meta.url));
const DIAGRAMS = join(__dir, 'diagrams');
const OUT = join(__dir, 'images');
mkdirSync(OUT, { recursive: true });

const files = [
  ['use-case.puml', '03-use-case-diagram.png'],
  ['activity-user.puml', '04-activity-diagram-user.png'],
  ['activity-admin.puml', '05-activity-diagram-admin.png'],
  ['er-diagram.puml', '06-er-diagram.png'],
  ['system-overview.puml', '01-gambaran-umum-sistem.png'],
];

async function renderPuml(sourcePath, outPath) {
  const source = readFileSync(sourcePath, 'utf8');
  const res = await fetch('https://kroki.io/plantuml/png', {
    method: 'POST',
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
    body: source,
  });
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Kroki failed ${res.status}: ${err.slice(0, 200)}`);
  }
  const buf = Buffer.from(await res.arrayBuffer());
  writeFileSync(outPath, buf);
  console.log('OK:', outPath, `(${(buf.length / 1024).toFixed(1)} KB)`);
}

for (const [src, dest] of files) {
  await renderPuml(join(DIAGRAMS, src), join(OUT, dest));
}

console.log('\nSemua diagram disimpan di:', OUT);
