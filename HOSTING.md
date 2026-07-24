# Panduan Hosting Gratis POLA

Deploy otomatis (gratis) untuk backend AI + website.

---

## 1. Google Gemini API Key (gratis)

1. Buka https://aistudio.google.com/apikey
2. Buat API key
3. Simpan untuk langkah backend

---

## 2. Backend AI di Render.com (gratis)

1. Push proyek ke **GitHub**
2. Daftar di https://render.com (gratis)
3. **New → Blueprint** → pilih repo → Render baca `render.yaml`
4. Isi environment variable:
   - `GEMINI_API_KEY` = API key dari langkah 1
5. Deploy selesai → catat URL, contoh: `https://pola-backend.onrender.com`
6. Tes: buka `https://pola-backend.onrender.com/health`

> **Catatan:** tier gratis Render "tidur" setelah ~15 menit idle. Request pertama bisa lambat 30–60 detik.

---

## 3. Supabase + Login Google

### Supabase
1. Buat proyek di https://supabase.com (gratis)
2. **SQL Editor** → jalankan file `supabase/migrations/20260609000000_initial_schema.sql`
3. **Settings → API** → salin `URL` dan `anon key`

### Google Cloud OAuth
1. Buka https://console.cloud.google.com/apis/credentials
2. Buat **OAuth client ID → Web application**
3. **Authorized JavaScript origins:**
   - `http://127.0.0.1:8081`
   - `https://YOUR-SITE.netlify.app` (URL website nanti)
4. **Authorized redirect URIs:**
   - `https://YOUR_PROJECT.supabase.co/auth/v1/callback`
5. Salin **Client ID** → isi di `.env` sebagai `GOOGLE_WEB_CLIENT_ID` dan `GOOGLE_SERVER_CLIENT_ID`

### Aktifkan Google di Supabase
1. **Authentication → Providers → Google** → Enable
2. Paste Client ID + Client Secret dari Google Cloud
3. **Authentication → URL Configuration:**
   - **Site URL:** `https://YOUR-SITE.netlify.app/app/`
   - **Redirect URLs:** tambahkan:
     - `https://YOUR-SITE.netlify.app/app/**`
     - `http://127.0.0.1:8081/app/**`

---

## 4. File `.env` (root proyek)

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
GOOGLE_WEB_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_SERVER_CLIENT_ID=xxxxx.apps.googleusercontent.com
POLA_BACKEND_URL=https://pola-backend.onrender.com
```

Salin juga ke `server/.env`:
```env
GEMINI_API_KEY=AIza...
GEMINI_MODEL=gemini-2.0-flash
```

---

## 5. Build website untuk production

```powershell
cd "c:\Users\ASUS\Documents\Chat Bot POLA"
$env:POLA_BACKEND_URL = "https://pola-backend.onrender.com"
powershell -ExecutionPolicy Bypass -File scripts\build_website.ps1
```

---

## 6. Website di Netlify (gratis)

**Opsi A — Drag & drop (paling cepat)**
1. Buka https://app.netlify.com/drop
2. Drag folder `releases\POLA-website`
3. Catat URL, mis. `https://pola-polibatam.netlify.app`

**Opsi B — GitHub (auto deploy)**
1. Connect repo di Netlify
2. Build command: kosongkan atau `echo skip`
3. Publish directory: `releases/POLA-website`
4. Netlify baca `netlify.toml` otomatis

Setelah deploy, update **Supabase Redirect URLs** dengan URL Netlify yang sebenarnya.

---

## 7. Tes

| Cek | URL |
|-----|-----|
| Backend | `https://pola-backend.onrender.com/health` |
| Website | `https://YOUR-SITE.netlify.app/` |
| Chatbot | `https://YOUR-SITE.netlify.app/app/` |
| Login Google | Masuk via tombol Google di aplikasi |

---

## Lokal (development)

```powershell
# Terminal 1 — backend
cd server
copy .env.example .env
# isi GEMINI_API_KEY
npm install
npm start

# Terminal 2 — website
powershell -ExecutionPolicy Bypass -File scripts\serve_website.ps1
```
