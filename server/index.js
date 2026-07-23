import path from 'path';
import { fileURLToPath } from 'url';
import { readFile } from 'fs/promises';

import cors from 'cors';
import dotenv from 'dotenv';
import express from 'express';

import { mountGoogleAuth, googleOauthConfigured } from './google_auth.js';
import { enrichCampusMedia } from './campus_media.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '.env') });

function envTrim(name) {
  const raw = process.env[name];
  if (raw == null) return '';
  return String(raw).replace(/^\uFEFF/, '').trim();
}

const PORT = Number(envTrim('PORT')) || 8787;
const KOBOI_API_KEY = envTrim('KOBOI_API_KEY');
const KOBOI_BASE_URL = (envTrim('KOBOI_BASE_URL') || 'https://api.koboillm.com/v1').replace(
  /\/$/,
  '',
);
const KOBOI_MODEL = envTrim('KOBOI_MODEL') || 'gemini/gemini-2.5-flash';
const GEMINI_API_KEY = envTrim('GEMINI_API_KEY');
const GEMINI_MODEL = envTrim('GEMINI_MODEL') || 'gemini-2.0-flash';
const HF_TOKEN = envTrim('HF_TOKEN');
const HF_MODEL = envTrim('HF_MODEL') || 'moonshotai/Kimi-K2-Instruct-0905';

const AI_PROVIDER = KOBOI_API_KEY
  ? 'koboillm'
  : GEMINI_API_KEY
    ? 'gemini'
    : HF_TOKEN
      ? 'huggingface'
      : 'none';

const ACTIVE_MODEL =
  AI_PROVIDER === 'koboillm'
    ? KOBOI_MODEL
    : AI_PROVIDER === 'gemini'
      ? GEMINI_MODEL
      : HF_MODEL;

const SYSTEM = `Kamu adalah POLA (Polibatam Assistant), asisten resmi untuk Politeknik Negeri Batam.
Aturan:
- Jawab dalam Bahasa Indonesia yang jelas dan sopan.
- Fokus pada Polibatam: akademik, jurusan, beasiswa, laboratorium, magang, layanan kampus, dan kehidupan kampus terkait Polibatam.
- Jika pertanyaan jelas di luar konteks Polibatam dan tidak ada informasi relevan di potongan basis pengetahuan, tolak singkat dan arahkan pengguna menanyakan hal terkait Polibatam.
- Jika ada potongan "basis pengetahuan internal" di bawah ini, utamakan fakta dari sana; jangan mengada-adakan detail spesifik kampus yang tidak didukung potongan tersebut atau pengetahuan umum yang wajar.
- Jika pengguna minta gambar, peta, foto, rute, atau arah ke gedung: jelaskan singkat lokasi/cara, dan sebut bahwa aplikasi akan menampilkan peta/rute interaktif di bawah jawaban.
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
      if (t) return t;
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

function normalizeHistory(conversationHistory) {
  if (!Array.isArray(conversationHistory)) return [];
  return conversationHistory
    .map((row) => {
      const role = row?.role === 'assistant' ? 'assistant' : 'user';
      const content = String(row?.content || '').trim();
      if (!content) return null;
      return { role, content };
    })
    .filter(Boolean)
    .slice(-10);
}

async function callOpenAiChat({
  url,
  apiKey,
  model,
  userText,
  conversationHistory = [],
}) {
  const messages = [{ role: 'system', content: SYSTEM.trim() }];
  for (const turn of normalizeHistory(conversationHistory)) {
    messages.push(turn);
  }
  messages.push({ role: 'user', content: userText });

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.7,
      max_tokens: 2048,
    }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg =
      data?.error?.message ||
      (typeof data?.error === 'string' ? data.error : '') ||
      res.statusText ||
      'AI request failed';
    const err = new Error(msg);
    err.status = res.status;
    throw err;
  }

  const text = data?.choices?.[0]?.message?.content;
  if (typeof text === 'string' && text.trim()) return text.trim();
  throw Object.assign(new Error('Model tidak mengembalikan teks.'), { status: 502 });
}

async function callKoboiLLM({ apiKey, baseUrl, model, userText, conversationHistory = [] }) {
  return callOpenAiChat({
    url: `${baseUrl}/chat/completions`,
    apiKey,
    model,
    userText,
    conversationHistory,
  });
}

async function callGemini({ apiKey, model, userText, conversationHistory = [] }) {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/` +
    `${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;

  const contents = normalizeHistory(conversationHistory).map((turn) => ({
    role: turn.role === 'assistant' ? 'model' : 'user',
    parts: [{ text: turn.content }],
  }));
  contents.push({ role: 'user', parts: [{ text: userText }] });

  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: SYSTEM.trim() }] },
      contents,
      generationConfig: { temperature: 0.7, maxOutputTokens: 2048 },
    }),
  });

  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg =
      data?.error?.message ||
      (typeof data?.error === 'string' ? data.error : '') ||
      res.statusText ||
      'Gemini request failed';
    const err = new Error(msg);
    err.status = res.status;
    throw err;
  }

  const parts = data?.candidates?.[0]?.content?.parts;
  const text = Array.isArray(parts)
    ? parts.map((p) => p?.text || '').join('').trim()
    : '';
  if (text) return text;
  throw Object.assign(new Error('Model Gemini tidak mengembalikan teks.'), { status: 502 });
}

async function callHfRouter({ token, model, userText, conversationHistory = [] }) {
  return callOpenAiChat({
    url: 'https://router.huggingface.co/v1/chat/completions',
    apiKey: token,
    model,
    userText,
    conversationHistory,
  });
}

async function generateReply({ userText, conversationHistory }) {
  if (KOBOI_API_KEY) {
    return callKoboiLLM({
      apiKey: KOBOI_API_KEY,
      baseUrl: KOBOI_BASE_URL,
      model: KOBOI_MODEL,
      userText,
      conversationHistory,
    });
  }
  if (GEMINI_API_KEY) {
    return callGemini({
      apiKey: GEMINI_API_KEY,
      model: GEMINI_MODEL,
      userText,
      conversationHistory,
    });
  }
  if (HF_TOKEN) {
    return callHfRouter({
      token: HF_TOKEN,
      model: HF_MODEL,
      userText,
      conversationHistory,
    });
  }
  const err = new Error(
    'AI belum dikonfigurasi. Isi KOBOI_API_KEY, GEMINI_API_KEY, atau HF_TOKEN di server/.env.',
  );
  err.status = 503;
  throw err;
}

const app = express();
app.use(cors({ origin: true }));
app.use(express.json({ limit: '512kb' }));

mountGoogleAuth(app);

app.get('/health', (_req, res) => {
  res.json({
    ok: AI_PROVIDER !== 'none',
    provider: AI_PROVIDER,
    koboiConfigured: Boolean(KOBOI_API_KEY),
    geminiConfigured: Boolean(GEMINI_API_KEY),
    hfConfigured: Boolean(HF_TOKEN),
    model: ACTIVE_MODEL,
    googleAuthConfigured: googleOauthConfigured(),
  });
});

app.post('/v1/chat', async (req, res) => {
  const { message, knowledgeSnippets, conversationHistory } = req.body || {};
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
    const reply = await generateReply({
      userText: fullPrompt,
      conversationHistory,
    });
    const media = enrichCampusMedia(msg);
    return res.json({
      reply,
      provider: AI_PROVIDER,
      images: media.images,
      routes: media.routes,
    });
  } catch (e) {
    const code = typeof e.status === 'number' ? e.status : 0;
    const status = code >= 400 && code < 600 ? code : 502;
    return res.status(status).json({
      error: e.message || 'Gagal memanggil AI.',
    });
  }
});

// Website download + Flutter web (satu hosting gratis: API + site).
const publicDir = path.join(__dirname, 'public');
app.use(express.static(publicDir, { fallthrough: true, index: ['index.html'] }));
app.get('/app', (_req, res) => res.redirect(301, '/app/'));
app.get(/^\/app\/.*$/, (req, res, next) => {
  // Flutter SPA: path tanpa ekstensi file → index.html
  if (path.extname(req.path)) return next();
  res.sendFile(path.join(publicDir, 'app', 'index.html'), (err) => {
    if (err) next();
  });
});
app.get(/^(?!\/v1\/|\/health).*/, (req, res, next) => {
  if (path.extname(req.path)) return next();
  res.sendFile(path.join(publicDir, 'index.html'), (err) => {
    if (err) next();
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(
    `POLA AI Backend (${AI_PROVIDER}) di http://localhost:${PORT}  (POST /v1/chat, GET /health)`,
  );
  console.log(`Website static: ${publicDir}`);
  console.log(
    `Google OAuth: ${googleOauthConfigured() ? 'configured' : 'NOT configured (set GOOGLE_CLIENT_ID/SECRET)'}`,
  );
  if (AI_PROVIDER === 'none') {
    console.warn('[POLA] Isi KOBOI_API_KEY di server/.env lalu restart.');
  }
});
