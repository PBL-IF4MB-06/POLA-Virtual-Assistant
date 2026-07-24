# Cara Pasang POLA di iPhone (Tanpa Mac)

Anda **tidak perlu Mac** dan **tidak perlu App Store**.  
Cara ini memasang POLA seperti aplikasi lewat **Safari → Add to Home Screen**.

---

## Persiapan (sekali saja)

1. PC Windows dan iPhone **WiFi yang sama** (hotspot HP juga bisa, asal PC connect ke hotspot itu).
2. Flutter & Python sudah terpasang di PC (sudah ada di proyek ini).
3. Backend AI siap — script di bawah akan menjalankannya otomatis jika belum jalan.

---

## Langkah install (5 menit)

### 1. Jalankan script di PC

Buka PowerShell di folder proyek:

```powershell
cd "c:\Users\ASUS\Documents\Chat Bot POLA"
powershell -ExecutionPolicy Bypass -File scripts\serve_ios_pwa.ps1
```

Tunggu sampai muncul link, contoh:

```
Link di iPhone: http://192.168.1.10:8080
```

**Jangan tutup** jendela PowerShell ini selama pakai POLA.

### 2. Di iPhone — buka Safari

> Wajib **Safari**, bukan Chrome. Fitur "Add to Home Screen" paling andal di Safari.

Ketik alamat yang muncul di script, misalnya: `http://192.168.1.10:8080`

### 3. Tambahkan ke Layar Utama

1. Tap ikon **Share** (kotak dengan panah ke atas)
2. Scroll → tap **Add to Home Screen** / **Tambahkan ke Layar Utama**
3. Nama: **POLA** → tap **Add** / **Tambah**

Selesai! Ikon POLA ada di layar utama seperti aplikasi biasa.

---

## Setiap kali mau pakai POLA

1. Jalankan lagi script `serve_ios_pwa.ps1` di PC (backend + web server harus jalan).
2. Buka ikon **POLA** di iPhone (atau buka link Safari lagi).

---

## Kalau tidak bisa dibuka di iPhone

| Masalah | Solusi |
|---------|--------|
| Halaman tidak load | PC & iPhone WiFi sama? Cek IP dengan `ipconfig` di PC |
| Windows Firewall block | Izinkan Python port **8080** dan Node port **8787** |
| Chatbot "Backend offline" | Pastikan jendela `npm start` di folder `server/` masih jalan |
| Tombol Share tidak ada | Pakai **Safari**, bukan Chrome |
| IP berubah | WiFi baru = IP baru → jalankan ulang script |

### Izinkan firewall Windows (jika perlu)

PowerShell **Run as Administrator**:

```powershell
New-NetFirewallRule -DisplayName "POLA Web" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
New-NetFirewallRule -DisplayName "POLA Backend" -Direction Inbound -Protocol TCP -LocalPort 8787 -Action Allow
```

---

## Apakah ini aplikasi asli iOS?

| | Native (.ipa) | Cara ini (PWA) |
|--|---------------|----------------|
| Butuh Mac | Ya | **Tidak** |
| Butuh App Store | Ya (umumnya) | **Tidak** |
| Ikon di layar utama | Ya | **Ya** |
| Buka fullscreen | Ya | **Ya** |
| Gratis | Butuh \$99/tahun (Developer) | **Gratis** |

Untuk demo PBL dan penggunaan pribadi di kampus, cara ini **sudah cukup**.

---

## Opsi lain (jika mau bisa diakses dari mana saja)

Upload folder `releases/POLA-web/` ke hosting gratis:

- [Netlify Drop](https://app.netlify.com/drop) — drag & drop folder
- [Vercel](https://vercel.com)
- GitHub Pages

Backend AI harus online juga (server kampus/VPS), lalu build web dengan URL backend publik:

```powershell
$env:POLA_BACKEND_URL = "https://pola-backend.polibatam.ac.id"
flutter build web --release --dart-define=POLA_BACKEND_URL=$env:POLA_BACKEND_URL
```

---

*POLA · Politeknik Negeri Batam*
