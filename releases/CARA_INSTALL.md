# Cara Install & Download POLA

Aplikasi **POLA — Chatbot AI Berbasis Mobile** bisa diinstal di:

| Platform | File | Status di PC Windows |
|----------|------|----------------------|
| **Android** | `POLA-v1.0.0-android.apk` | ✅ Bisa di-build di sini |
| **PC (browser)** | folder `POLA-web/` | ✅ Bisa di-build di sini |
| **PC (Windows app)** | folder `POLA-v1.0.0-windows/` | ⚠️ Butuh Visual Studio C++ |
| **iOS (iPhone/iPad)** | `.ipa` | ⚠️ Hanya di Mac + Xcode |

---

## 1. Android — Download & Install APK

### Build (developer)
```powershell
cd c:\Users\ASUS\Documents\POLA-Virtual-Assistant
powershell -ExecutionPolicy Bypass -File scripts\build_release.ps1
```

File hasil: `releases\POLA-v1.0.0-android.apk`

### Install di HP Android
1. Salin file `.apk` ke HP (USB, Google Drive, atau WhatsApp).
2. Buka file → izinkan **Install dari sumber tidak dikenal**.
3. Tap **Install**.

### Penting — Chatbot AI di HP fisik
Backend AI harus bisa diakses HP. **127.0.0.1 tidak bisa** dipakai di HP (itu localhost HP, bukan PC).

1. Jalankan server di PC:
   ```powershell
   cd server
   npm start
   ```
2. Cari IP PC (WiFi): `ipconfig` → contoh `192.168.1.10`
3. Build ulang APK dengan IP tersebut:
   ```powershell
   $env:POLA_BACKEND_URL = "http://192.168.1.10:8787"
   flutter build apk --release --dart-define=POLA_BACKEND_URL=$env:POLA_BACKEND_URL
   ```
4. HP dan PC harus **WiFi yang sama**.

---

## 2. PC — Pakai versi Web (paling mudah)

### Build
```powershell
flutter build web --release --dart-define=POLA_BACKEND_URL=http://127.0.0.1:8787
```

Hasil: `build\web\` atau `releases\POLA-web\`

### Jalankan lokal
```powershell
# Terminal 1 — backend
cd server && npm start

# Terminal 2 — serve web
cd build\web
python -m http.server 8080
```
Buka browser: **http://localhost:8080**

### Upload ke internet (opsional)
Upload folder `POLA-web` ke:
- GitHub Pages
- Netlify / Vercel
- Hosting kampus

---

## 3. PC — Aplikasi Windows (.exe)

**Syarat:** Install [Visual Studio](https://visualstudio.microsoft.com/) dengan workload **"Desktop development with C++"**.

```powershell
flutter build windows --release --dart-define=POLA_BACKEND_URL=http://127.0.0.1:8787
```

Jalankan: `build\windows\x64\runner\Release\pola_app.exe`

Sebelum pakai chatbot, jalankan juga `npm start` di folder `server/`.

---

## 4. iOS (iPhone/iPad)

> **Penting:** iOS **tidak memakai APK**. Format native iOS adalah **`.ipa`**.  
> Build `.ipa` **tidak bisa di Windows** — wajib **Mac + Xcode**.

### Opsi A — Install lewat Safari (bisa sekarang, tanpa Mac)

Cara paling praktis untuk demo/PBL jika belum punya Mac:

1. Host folder `releases/POLA-web/` di internet (Netlify, Vercel, GitHub Pages, atau server kampus).
2. Buka link tersebut di **Safari** di iPhone/iPad.
3. Tap **Share** (ikon kotak + panah) → **Add to Home Screen** → **Add**.
4. Ikon **POLA** muncul di layar utama seperti aplikasi native.

Backend AI tetap harus bisa diakses iPhone (IP PC di WiFi yang sama, bukan `127.0.0.1`). Build ulang web dengan IP yang benar:

```powershell
$env:POLA_BACKEND_URL = "http://192.168.1.10:8787"
flutter build web --release --dart-define=POLA_BACKEND_URL=$env:POLA_BACKEND_URL
# Salin build\web\ ke releases\POLA-web\
```

### Opsi B — Aplikasi native `.ipa` (butuh Mac)

Di Mac dengan Xcode terpasang:

```bash
cd "Chat Bot POLA"
chmod +x scripts/build_ios.sh
export POLA_BACKEND_URL="http://192.168.1.10:8787"
./scripts/build_ios.sh
```

File hasil: `releases/POLA-v1.0.0-ios.ipa`

**Distribusi ke pengguna iOS:**

| Metode | Syarat | Cocok untuk |
|--------|--------|-------------|
| **TestFlight** | Apple Developer ($99/tahun) | Uji coba ke banyak iPhone |
| **App Store** | Apple Developer + review Apple | Publik umum |
| **Xcode langsung** | Mac + kabel USB + device terdaftar | Dev / demo kecil |
| **Add to Home Screen** | Host versi web | PBL / kampus tanpa Mac |

Apple **tidak mengizinkan** install `.ipa` langsung dari file seperti APK Android (kecuali lewat TestFlight, App Store, atau Xcode ke device terdaftar).

---

## 5. Upload ke Play Store / App Store (opsional)

| Store | Format | Catatan |
|-------|--------|---------|
| Google Play | `flutter build appbundle` → `.aab` | Butuh akun Google Play Developer |
| App Store | `.ipa` via Xcode | Butuh Apple Developer |

Untuk proyek PBL/kampus, biasanya cukup **bagikan APK** langsung ke dosen/mahasiswa.

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| Chatbot "Backend offline" | Pastikan `npm start` jalan di folder `server/` |
| HP tidak bisa connect | Ganti URL ke IP PC, bukan 127.0.0.1 |
| Windows build gagal | Install Visual Studio C++ workload |
| iOS tidak bisa build | Pakai Mac atau minta bantuan lab Mac kampus |

---

*POLA · Politeknik Negeri Batam*
