import path from 'path';
import { fileURLToPath } from 'url';

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
const GEMINI_KEY = envTrim('GEMINI_API_KEY');

const SYSTEM = `Kamu adalah POLA (Polibatam Assistant), asisten resmi untuk Politeknik Negeri Batam.
Aturan:
- Jawab dalam Bahasa Indonesia yang jelas dan sopan.
- Fokus pada Polibatam: akademik, jurusan, beasiswa, laboratorium, magang, layanan kampus, dan kehidupan kampus terkait Polibatam.
- Jika pertanyaan jelas di luar konteks Polibatam dan tidak ada informasi relevan di potongan basis pengetahuan, tolak singkat dan arahkan pengguna menanyakan hal terkait Polibatam.
- Jika ada potongan "basis pengetahuan internal" di bawah ini, utamakan fakta dari sana; jangan mengada-adakan detail spesifik kampus yang tidak didukung potongan tersebut atau pengetahuan umum yang wajar.
- Hindari klaim legal/medis yang tidak perlu; tetap informatif untuk mahasiswa/kalangan kampus.`;

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

async function callGemini(modelId, userText) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${modelId}:generateContent?key=${encodeURIComponent(GEMINI_KEY)}`;
  const body = {
    systemInstruction: {
      parts: [{ text: SYSTEM }],
    },
    contents: [
      {
        role: 'user',
        parts: [{ text: userText }],
      },
    ],
  };
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = data?.error?.message || res.statusText || 'Gemini request failed';
    const err = new Error(msg);
    err.status = res.status;
    throw err;
  }
  const parts = data?.candidates?.[0]?.content?.parts;
  const text = parts?.map((p) => p.text).filter(Boolean).join('')?.trim();
  if (!text) {
    const block = data?.promptFeedback?.blockReason;
    const msg = block
      ? `Respons Gemini diblokir (${block}). Coba ubah redaksi pertanyaan.`
      : 'Model tidak mengembalikan teks (candidates kosong).';
    const err = new Error(msg);
    err.status = 502;
    throw err;
  }
  return text;
}

async function generateReply(userText) {
  const models = ['gemini-2.0-flash', 'gemini-1.5-flash'];
  let lastErr;
  for (const m of models) {
    try {
      return await callGemini(m, userText);
    } catch (e) {
      lastErr = e;
    }
  }
  throw lastErr || new Error('Gemini failed');
}

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '512kb' }));

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    geminiConfigured: Boolean(GEMINI_KEY),
  });
});

app.post('/v1/chat', async (req, res) => {
  if (!GEMINI_KEY) {
    return res.status(503).json({
      error: 'GEMINI_API_KEY belum di-set di file .env server.',
    });
  }
  const { message, knowledgeSnippets } = req.body || {};
  const msg = typeof message === 'string' ? message : '';
  if (!msg.trim()) {
    return res.status(400).json({ error: 'Field "message" wajib diisi.' });
  }
  try {
    const prompt = buildUserPrompt(msg, knowledgeSnippets);
    const reply = await generateReply(prompt);
    return res.json({ reply });
  } catch (e) {
    const code = typeof e.status === 'number' ? e.status : 0;
    const status = code >= 400 && code < 600 ? code : 502;
    return res.status(status).json({
      error: e.message || 'Gagal memanggil Gemini.',
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`POLA AI backend http://localhost:${PORT}  (POST /v1/chat, GET /health)`);
  if (!GEMINI_KEY) {
    console.warn('[POLA] GEMINI_API_KEY kosong — isi server/.env lalu restart.');
  }
});
