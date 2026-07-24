# POLA — ChatBot

**POLA** (*Polibatam Assistant*) adalah asisten virtual berbasis AI untuk **Politeknik Negeri Batam (Polibatam)**. Aplikasi ini membantu mahasiswa, calon mahasiswa, dan civitas kampus mendapatkan informasi seputar akademik, jurusan, beasiswa, laboratorium, magang, dan layanan kampus lainnya.

Dibangun dengan **Flutter** (multi-platform) dan backend AI Node.js yang terhubung ke **Hugging Face Router**, dengan dukungan opsional **Supabase** untuk autentikasi dan sinkronisasi data.

---

## Dibuat Oleh

| Nama | Institusi |
|------|-----------|
| **Bindhu Owen Batami Hutagalung** | Politeknik Negeri Batam |
| **Muhammad Nabil** | Politeknik Negeri Batam |

---

## Fitur Utama

- **Chat AI** — Tanya jawab interaktif seputar Polibatam dengan antarmuka mirip asisten modern
- **Basis pengetahuan lokal** — FAQ dan dokumen kampus diindeks untuk konteks jawaban yang lebih akurat
- **Backend AI** — Model bahasa besar via Hugging Face (token disimpan aman di server, bukan di aplikasi)
- **Riwayat percakapan** — Simpan dan kelola banyak sesi chat dari drawer sisi kiri
- **Input suara** — Ketik pertanyaan atau gunakan speech-to-text
- **Lampiran gambar** — Kirim konteks tambahan berupa gambar
- **Login & sinkronisasi** — Akun email/password atau Google Sign-In (membutuhkan Supabase)
- **Mode gelap & preferensi** — Bahasa, haptik, efek suara, dan kustomisasi tampilan
- **Panel admin** — Kelola FAQ untuk pengguna dengan peran admin
- **Pencarian web (opsional)** — Google Custom Search hanya aktif jika pertanyaan menyebut *Polibatam*

---

## Teknologi

| Lapisan | Teknologi |
|---------|-----------|
| Aplikasi mobile/desktop/web | Flutter 3.x, Dart |
| Backend AI | Node.js, Express, Hugging Face Router API |
| Database & Auth (opsional) | Supabase (PostgreSQL) |
| AI tambahan | Google Generative AI, speech_to_text |

**Platform yang didukung:** Android, iOS, Windows, macOS, Linux, Web

---

## Prasyarat

Sebelum menjalankan proyek, pastikan sudah terpasang:

1. **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (SDK Dart ^3.9.2)
2. **[Node.js](https://nodejs.org/)** versi 18 atau lebih baru (untuk backend AI)
3. **Akun Hugging Face** — untuk token API ([buat di sini](https://huggingface.co/settings/tokens))
4. **Akun Supabase** *(opsional)* — jika ingin login, sinkronisasi chat, dan fitur admin cloud
5. **Android Studio / Xcode / VS Code** — sesuai platform target Anda

Verifikasi instalasi Flutter:

```bash
flutter doctor
```

---

## Instalasi

### 1. Clone repositori

```bash
git clone https://github.com/<username>/POLA-Virtual-Assistant.git
cd POLA-Virtual-Assistant
```

### 2. Instal dependensi Flutter

```bash
flutter pub get
```

### 3. Konfigurasi environment aplikasi

Salin file contoh dan isi nilai aslinya:

```bash
cp .env.example .env
```

Isi minimal di `.env` (root proyek):

```env
SUPABASE_URL=https://<project-id>.supabase.co
SUPABASE_ANON_KEY=<anon-key-anda>

# Opsional — Google OAuth
# GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
# GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com

# Opsional — override URL backend AI
# POLA_BACKEND_URL=http://127.0.0.1:8787
```

> **Catatan:** File `.env` tidak di-commit ke Git. Tanpa Supabase, aplikasi tetap bisa dijalankan dalam mode lokal (chat disimpan di perangkat).

### 4. Konfigurasi backend AI

```bash
cd server
npm install
cp .env.example .env
```

Isi `server/.env`:

```env
HF_TOKEN=hf_xxxxxxxxxxxxxxxx
HF_MODEL=moonshotai/Kimi-K2-Instruct-0905
PORT=8787
```

Jalankan server:

```bash
npm start
```

Server akan berjalan di `http://localhost:8787`. Cek kesehatan:

```bash
curl http://localhost:8787/health
```

### 5. (Opsional) Setup Supabase

1. Buat proyek baru di [supabase.com](https://supabase.com)
2. Jalankan skema database dari file `supabase/migrations/20260609000000_initial_schema.sql` melalui **SQL Editor** di dashboard Supabase
3. Salin **Project URL** dan **anon key** ke file `.env` aplikasi
4. Aktifkan provider **Email** dan/atau **Google** di Authentication → Providers

---

## Menjalankan Aplikasi

Pastikan backend AI sudah berjalan (`npm start` di folder `server/`), lalu:

```bash
# Dari root proyek
flutter run
```

Pilih perangkat yang tersedia (emulator, perangkat fisik, atau desktop).

### URL backend per platform (mode debug)

| Platform | URL default |
|----------|-------------|
| Windows / macOS / Linux / Web / iOS | `http://127.0.0.1:8787` |
| Android Emulator | `http://10.0.2.2:8787` |
| Perangkat Android fisik | Gunakan IP LAN komputer Anda, mis. `http://192.168.1.10:8787` |

Override URL saat build/run:

```bash
flutter run --dart-define=POLA_BACKEND_URL=http://192.168.1.10:8787
```

---

## Cara Menggunakan

### Memulai chat

1. Buka aplikasi POLA
2. Ketik pertanyaan di kolom input bawah layar, misalnya:
   - *"Beasiswa apa saja yang tersedia di Polibatam?"*
   - *"Bagaimana prosedur peminjaman laboratorium di Polibatam?"*
   - *"Jelaskan alur PBL di Polibatam."*
3. Tekan tombol kirim atau gunakan ikon **mikrofon** untuk input suara
4. POLA akan menjawab berdasarkan basis pengetahuan internal dan model AI

### Menu & riwayat

- Tap ikon **menu** (☰) di kiri atas untuk membuka drawer
- Pilih **Chat baru** untuk memulai percakapan baru
- Tap riwayat percakapan lama untuk melanjutkan chat sebelumnya

### Login (opsional)

- Buka **Pengaturan** dari drawer → **Login / Register**
- Daftar dengan email/password atau masuk via **Google**
- Setelah login, profil dan riwayat dapat disinkronkan ke Supabase

### Pengaturan

Di halaman **Pengaturan** Anda dapat mengatur:

- Mode gelap / terang
- Bahasa aplikasi (Indonesia / English)
- Umpan balik haptik, koreksi ejaan, efek suara
- Profil, ganti kata sandi, logout
- **Admin Panel** *(hanya untuk akun admin)*

### Tips mendapatkan jawaban terbaik

- Fokuskan pertanyaan pada topik **Polibatam** (akademik, jurusan, beasiswa, lab, magang, dll.)
- Sebutkan **"Polibatam"** jika ingin jawaban memanfaatkan pencarian web
- Pertanyaan di luar konteks kampus mungkin ditolak oleh asisten
- Untuk konteks tambahan, lampirkan gambar relevan bersama pertanyaan singkat

---

## Menambah Basis Pengetahuan

### Dataset kustom (backend)

Edit file `dataset_custom.txt` di root proyek dengan FAQ, kebijakan, atau info kampus. Server AI akan otomatis membacanya sebagai konteks tambahan saat menjawab.

### File lokal di aplikasi

Letakkan dokumen teks di folder `brand/knowledge/` agar diindeks oleh knowledge base aplikasi.

### Admin Panel

Pengguna dengan peran **admin** dapat menambah/mengubah FAQ langsung dari aplikasi melalui **Admin Panel** di Pengaturan.

---

## Struktur Proyek

```
POLA-Virtual-Assistant/
├── lib/                    # Kode sumber Flutter
│   ├── pages/              # Halaman UI (chat, login, settings, admin)
│   ├── services/           # Logika bot, AI, Supabase, speech
│   ├── state/              # State management (auth, chat, settings)
│   └── config/             # Konfigurasi environment & backend
├── server/                 # Backend AI (Node.js + Hugging Face)
├── supabase/               # Migrasi & seed database
├── brand/                  # Logo & file knowledge lokal
├── dataset_custom.txt      # Dataset tambahan untuk backend AI
├── .env.example            # Template env aplikasi
└── pubspec.yaml            # Dependensi Flutter
```

---

## Pengujian

Jalankan unit test Flutter:

```bash
flutter test
```

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Chat tidak mendapat jawaban AI | Pastikan `server/` berjalan dan `HF_TOKEN` sudah diisi |
| `HF_TOKEN belum di-set` | Isi token di `server/.env`, lalu restart server |
| Android tidak bisa hubung ke backend | Gunakan `10.0.2.2` (emulator) atau IP LAN (perangkat fisik) |
| Login gagal | Periksa `SUPABASE_URL` dan `SUPABASE_ANON_KEY` di `.env` |
| File `.env` tidak terbaca | Pastikan file ada di root proyek (bukan hanya `.env.example`) |

---

## Lisensi

Proyek ini dikembangkan sebagai bagian dari kegiatan akademik di **Politeknik Negeri Batam**. Hubungi penulis jika Anda ingin menggunakan atau mendistribusikan ulang kode ini.

---

## Kontak & Institusi

**Politeknik Negeri Batam (Polibatam)**  
Website: [https://polibatam.ac.id](https://polibatam.ac.id)

*POLA — Asisten virtual untuk civitas Polibatam.*
