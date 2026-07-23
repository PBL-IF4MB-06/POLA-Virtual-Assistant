import crypto from 'crypto';

function envTrim(name) {
  const raw = process.env[name];
  if (raw == null) return '';
  return String(raw).replace(/^\uFEFF/, '').trim();
}

function b64url(buf) {
  return Buffer.from(buf)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/g, '');
}

function fromB64url(str) {
  const pad = str.length % 4 === 0 ? '' : '='.repeat(4 - (str.length % 4));
  const s = str.replace(/-/g, '+').replace(/_/g, '/') + pad;
  return Buffer.from(s, 'base64');
}

export function googleOauthConfigured() {
  return Boolean(envTrim('GOOGLE_CLIENT_ID') && envTrim('GOOGLE_CLIENT_SECRET'));
}

function sessionSecret() {
  return (
    envTrim('POLA_SESSION_SECRET') ||
    envTrim('GOOGLE_CLIENT_SECRET') ||
    'pola-dev-session-secret'
  );
}

export function signGoogleSession({ email, name, picture = '' }) {
  const payload = {
    email: String(email || '').trim().toLowerCase(),
    name: String(name || '').trim(),
    picture: String(picture || '').trim(),
    exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30,
  };
  const body = b64url(JSON.stringify(payload));
  const sig = b64url(
    crypto.createHmac('sha256', sessionSecret()).update(body).digest(),
  );
  return `${body}.${sig}`;
}

export function verifyGoogleSession(token) {
  if (!token || typeof token !== 'string' || !token.includes('.')) return null;
  const [body, sig] = token.split('.');
  if (!body || !sig) return null;
  const expected = b64url(
    crypto.createHmac('sha256', sessionSecret()).update(body).digest(),
  );
  const a = Buffer.from(sig);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) return null;
  try {
    const payload = JSON.parse(fromB64url(body).toString('utf8'));
    if (!payload?.email || !payload?.exp) return null;
    if (payload.exp < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

function publicBase(req) {
  const fromEnv = envTrim('PUBLIC_BASE_URL').replace(/\/$/, '');
  if (fromEnv) return fromEnv;
  const proto = (req.headers['x-forwarded-proto'] || req.protocol || 'https')
    .toString()
    .split(',')[0]
    .trim();
  const host = (req.headers['x-forwarded-host'] || req.headers.host || '')
    .toString()
    .split(',')[0]
    .trim();
  return `${proto}://${host}`;
}

function safeRedirect(raw, fallback) {
  const s = String(raw || '').trim();
  if (!s) return fallback;
  try {
    const u = new URL(s);
    // Izinkan hanya http(s) — redirect kembali ke app Flutter.
    if (u.protocol !== 'http:' && u.protocol !== 'https:') return fallback;
    return u.toString();
  } catch {
    return fallback;
  }
}

/**
 * Pasang route Google OAuth di Express app.
 * GET  /auth/google?redirect=<appUrl>
 * GET  /auth/google/callback
 * GET  /auth/google/status
 * POST /auth/google/verify  { token }
 */
export function mountGoogleAuth(app) {
  const pending = new Map(); // state -> { redirect, ts }

  setInterval(() => {
    const now = Date.now();
    for (const [k, v] of pending) {
      if (now - v.ts > 15 * 60 * 1000) pending.delete(k);
    }
  }, 60_000).unref?.();

  app.get('/auth/google/status', (_req, res) => {
    res.json({
      configured: googleOauthConfigured(),
      provider: 'google',
    });
  });

  app.post('/auth/google/verify', (req, res) => {
    const token = String(req.body?.token || '');
    const payload = verifyGoogleSession(token);
    if (!payload) {
      return res.status(401).json({ error: 'Token tidak valid atau kedaluwarsa.' });
    }
    return res.json({
      email: payload.email,
      name: payload.name,
      picture: payload.picture || '',
    });
  });

  app.get('/auth/google', (req, res) => {
    if (!googleOauthConfigured()) {
      return res.status(503).send(setupHtml(publicBase(req)));
    }

    const base = publicBase(req);
    const fallback = `${base}/app/`;
    const redirect = safeRedirect(req.query.redirect, fallback);
    const state = b64url(crypto.randomBytes(24));
    pending.set(state, { redirect, ts: Date.now() });

    const params = new URLSearchParams({
      client_id: envTrim('GOOGLE_CLIENT_ID'),
      redirect_uri: `${base}/auth/google/callback`,
      response_type: 'code',
      scope: 'openid email profile',
      access_type: 'online',
      include_granted_scopes: 'true',
      prompt: 'select_account',
      state,
    });

    return res.redirect(
      `https://accounts.google.com/o/oauth2/v2/auth?${params.toString()}`,
    );
  });

  app.get('/auth/google/callback', async (req, res) => {
    const base = publicBase(req);
    const fallback = `${base}/app/`;

    try {
      if (!googleOauthConfigured()) {
        return res.status(503).send(setupHtml(base));
      }

      const { code, state, error } = req.query;
      if (error) {
        return res.status(400).send(`Login Google dibatalkan: ${error}`);
      }
      const entry = pending.get(String(state || ''));
      pending.delete(String(state || ''));
      if (!code || !entry) {
        return res.status(400).send('State OAuth tidak valid. Coba login Google lagi.');
      }

      const redirectUri = `${base}/auth/google/callback`;
      const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          code: String(code),
          client_id: envTrim('GOOGLE_CLIENT_ID'),
          client_secret: envTrim('GOOGLE_CLIENT_SECRET'),
          redirect_uri: redirectUri,
          grant_type: 'authorization_code',
        }),
      });
      const tokenData = await tokenRes.json().catch(() => ({}));
      if (!tokenRes.ok || !tokenData.access_token) {
        const msg = tokenData.error_description || tokenData.error || 'Gagal tukar kode Google.';
        return res.status(502).send(String(msg));
      }

      const profileRes = await fetch('https://openidconnect.googleapis.com/v1/userinfo', {
        headers: { Authorization: `Bearer ${tokenData.access_token}` },
      });
      const profile = await profileRes.json().catch(() => ({}));
      if (!profileRes.ok || !profile.email) {
        return res.status(502).send('Gagal membaca profil Google.');
      }

      const session = signGoogleSession({
        email: profile.email,
        name: profile.name || profile.given_name || profile.email.split('@')[0],
        picture: profile.picture || '',
      });

      const dest = new URL(entry.redirect || fallback);
      dest.searchParams.set('pola_google', session);
      return res.redirect(dest.toString());
    } catch (e) {
      console.error('google callback failed', e);
      return res.status(500).send('Login Google gagal. Coba lagi.');
    }
  });
}

function setupHtml(base) {
  return `<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Setup Login Google — POLA</title>
<style>
body{font-family:system-ui,sans-serif;max-width:640px;margin:40px auto;padding:0 16px;line-height:1.5;color:#0f172a}
code,li{font-size:14px} .box{background:#f1f5f9;border-radius:12px;padding:16px;margin:16px 0}
a{color:#2563eb}
</style></head><body>
<h1>Login Google belum dikonfigurasi</h1>
<p>Isi <b>GOOGLE_CLIENT_ID</b> dan <b>GOOGLE_CLIENT_SECRET</b> di Railway (Variables), lalu redeploy.</p>
<div class="box">
<ol>
<li>Buka <a href="https://console.cloud.google.com/apis/credentials" target="_blank">Google Cloud Credentials</a></li>
<li>Buat OAuth Client → <b>Web application</b></li>
<li>Authorized JavaScript origins: <code>${base}</code></li>
<li>Authorized redirect URIs: <code>${base}/auth/google/callback</code></li>
<li>Salin Client ID + Client Secret → Railway Variables</li>
</ol>
</div>
<p>Setelah variabel terisi, buka lagi: <a href="${base}/auth/google?redirect=${encodeURIComponent(base + '/app/')}"><code>/auth/google</code></a></p>
</body></html>`;
}
