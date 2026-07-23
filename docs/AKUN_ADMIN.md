# Akun Admin POLA

Dokumen ini berisi kredensial default untuk mengakses **Panel Admin** pada aplikasi POLA (*Implementasi Chatbot AI pada Aplikasi POLA Berbasis Mobile*).

## Cara Masuk Admin

1. Buka aplikasi POLA
2. Masuk ke tab **Profil** → **Login Admin**  
   *(atau Pengaturan → Login Admin)*
3. Masukkan email dan password admin
4. Setelah berhasil, Anda akan diarahkan ke **Admin Dashboard**

---

## Akun Demo (Mode Lokal — Tanpa Supabase)

Digunakan saat aplikasi dijalankan tanpa konfigurasi Supabase (mode demo/offline).

| Field | Nilai |
|-------|-------|
| **Email** | `admin@pola.app` |
| **Password** | `admin12345` |

---

## Akun Admin Supabase (Production / Cloud)

Digunakan saat Supabase sudah dikonfigurasi di file `.env`.

| Field | Nilai |
|-------|-------|
| **Email** | `admin@polibatam.ac.id` |
| **Password** | `AdminPola2026!` |

Setup database admin: jalankan `supabase/setup_admin.sql` di Supabase SQL Editor, atau script `scripts/setup_admin.ps1`.

---

## Fitur Panel Admin

| Tab | Fungsi |
|-----|--------|
| **Ringkasan** | Statistik percakapan, pesan, dan jumlah FAQ |
| **FAQ** | Tambah, edit, hapus entri FAQ knowledge base |
| **Riwayat Chat** | Pantau percakapan yang tersimpan |
| **Kelola Admin** | Grant role admin ke email pengguna lain |

---

## Catatan Keamanan

- Ganti password default sebelum deploy ke produksi.
- Jangan commit file `.env` atau kredensial ke repository publik.
- Role admin disimpan di `profiles.role` (Supabase) atau `pola_auth_admins_v1` (lokal).

---

*POLA — Politeknik Negeri Batam · PBL IF-4MB-06*
