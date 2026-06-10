import path from 'path';
import { fileURLToPath } from 'url';
import { readFile } from 'fs/promises';

import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
// Selalu baca server/.env (bukan cwd proyek), supaya `node index.js` dari folder mana pun tetap jalan.
dotenv.config({ path: path.join(__dirname, '.env') });

function envTrim(name) {
  const raw = process.env[name];
  if (raw == null) return '';
  return String(raw).replace(/^\uFEFF/, '').trim();
}

const PORT = Number(envTrim('PORT')) || 8787;
const HF_TOKEN = envTrim('HF_TOKEN');
const HF_MODEL = envTrim('HF_MODEL') || 'moonshotai/Kimi-K2-Instruct-0905';

const SYSTEM = `Kamu adalah POLA (Polibatam Assistant), asisten resmi untuk Politeknik Negeri Batam.
Aturan:
- Jawab dalam Bahasa Indonesia yang jelas dan sopan.
- Fokus pada Polibatam: akademik, jurusan, beasiswa, laboratorium, magang, layanan kampus, dan kehidupan kampus terkait Polibatam.
- Jika pertanyaan jelas di luar konteks Polibatam dan tidak ada informasi relevan di potongan basis pengetahuan, tolak singkat dan arahkan pengguna menanyakan hal terkait Polibatam.
- Jika ada potongan "basis pengetahuan internal" di bawah ini, utamakan fakta dari sana; jangan mengada-adakan detail spesifik kampus yang tidak didukung potongan tersebut atau pengetahuan umum yang wajar.
- Hindari klaim legal/medis yang tidak perlu; tetap informatif untuk mahasiswa/kalangan kampus.`;

async function loadDatasetCustom() {
  const candidates = [
    path.join(__dirname, 'dataset_custom.txt'),
    path.join(__dirname, '..', 'dataset_custom.txt'),
  ];
  for (const p of candidates) {
    try {
      const raw = await readFile(p, 'utf8');
      const t = String(raw || '').trim();
      if (!t) continue;
      return t;
    } catch (_) {}
  }
  return '';
}

function buildUserPrompt(message, knowledgeSnippets) {
  const b = [];
  if (Array.isArray(knowledgeSnippets) && knowledgeSnippets.length > 0) {
    b.push('Potongan basis pengetahuan internal (prioritaskan jika relevan):');
    knowledgeSnippets.forEach((row, i) => {
      const title = String(row.sourceTitle || row.title || `Sumber ${i + 1}`);
      const text = String(row.text || '').trim();
      b.push('');
      b.push(`--- ${i + 1}. ${title} ---`);
      b.push(text);
    });
    b.push('');
  }
  b.push('Pertanyaan pengguna:');
  b.push(String(message || '').trim());
  return b.join('\n');
}

async function callHfRouter({ token, model, userText }) {
  const url = 'https://router.huggingface.co/v1/chat/completions';
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      model,
      messages: [
        { role: 'system', content: SYSTEM.trim() },
        { role: 'user', content: userText },
      ],
    }),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg =
      (data && typeof data === 'object' && data.error ? String(data.error) : '') ||
      res.statusText ||
      'Hugging Face request failed';
    const err = new Error(msg);
    err.status = res.status;
    throw err;
  }
  const text = data?.choices?.[0]?.message?.content;
  if (typeof text === 'string' && text.trim()) return text.trim();
  throw Object.assign(new Error('Model tidak mengembalikan teks.'), { status: 502 });
}

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '512kb' }));

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    hfConfigured: Boolean(HF_TOKEN),
    model: HF_MODEL,
  });
});

app.post('/v1/chat', async (req, res) => {
  if (!HF_TOKEN) {
    return res.status(503).json({
      error: 'HF_TOKEN belum di-set di file .env server.',
    });
  }
  const { message, knowledgeSnippets } = req.body || {};
  const msg = typeof message === 'string' ? message : '';
  if (!msg.trim()) {
    return res.status(400).json({ error: 'Field "message" wajib diisi.' });
  }
  try {
    const prompt = buildUserPrompt(msg, knowledgeSnippets);
    const dataset = await loadDatasetCustom();
    const fullPrompt = dataset
      ? `${prompt}\n\nBasis pengetahuan tambahan (dataset_custom.txt):\n${dataset}`
      : prompt;
    const reply = await callHfRouter({
      token: HF_TOKEN,
      model: HF_MODEL,
      userText: fullPrompt,
    });
    return res.json({ reply });
  } catch (e) {
    const code = typeof e.status === 'number' ? e.status : 0;
    const status = code >= 400 && code < 600 ? code : 502;
    return res.status(status).json({
      error: e.message || 'Gagal memanggil Hugging Face.',
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`POLA AI Backend berjalan di http://localhost:${PORT}  (POST /v1/chat, GET /health)`);
  if (!HF_TOKEN) {
    console.warn('[POLA] HF_TOKEN kosong — isi server/.env lalu restart.');
  }
});
