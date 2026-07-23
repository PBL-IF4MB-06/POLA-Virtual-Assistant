# DRAFT PROPOSAL TUGAS AKHIR

---

**JUDUL**

# APLIKASI MOBILE POLA — POLIBATAM AI ASSISTANT

---

| | |
|---|---|
| **Nama Mahasiswa** | Muhammad Nabil |
| **NIM** | 3312411007 |
| **Program Studi** | D-III Teknik Informatika |
| **Institusi** | Politeknik Negeri Batam |
| **Tahun Ajaran** | 2025/2026 |

---

## 1. Latar Belakang

Politeknik Negeri Batam (Polibatam) memiliki berbagai layanan informasi akademik dan kemahasiswaan yang tersebar di berbagai kanal, seperti Sistem Informasi Akademik (SIA), website kampus, pengumuman, dan komunikasi langsung dengan bagian administrasi. Mahasiswa dan civitas kampus sering membutuhkan informasi cepat mengenai jadwal kuliah, KRS, beasiswa, magang, fasilitas kampus, dan prosedur administratif.

Selama proses pembelajaran berbasis proyek (PBL), telah dikembangkan prototipe sistem informasi berbasis mobile dengan pendekatan **chatbot** untuk membantu pengguna mendapatkan jawaban seputar kampus. Namun, pengalaman pengguna masih terbatas pada antarmuka percakapan berbasis teks yang kurang interaktif dan kurang memberikan kesan asisten digital yang mendampingi pengguna secara visual.

Perkembangan teknologi kecerdasan buatan (AI) dan animasi antarmuka mobile memungkinkan dibuatnya **asisten virtual (AI Assistant)** yang tidak hanya menjawab pertanyaan, tetapi juga tampil dengan karakter visual animasi, umpan balik interaktif, dan pengalaman pengguna yang lebih natural. Asisten AI diposisikan berbeda dari chatbot konvensional karena menekankan **pendampingan kontekstual, respons visual, dan interaksi multimodal** (teks, suara, animasi status).

Berdasarkan hal tersebut, penulis merencanakan pengembangan lanjutan menjadi aplikasi mobile **POLA (Polibatam AI Assistant)** yang mengintegrasikan AI Assistant beranimasi sebagai pusat interaksi pengguna dengan layanan informasi kampus Polibatam.

---

## 2. Rumusan Masalah

Berdasarkan latar belakang di atas, rumusan masalah pada tugas akhir ini adalah:

1. Bagaimana merancang aplikasi mobile POLA yang menampilkan **AI Assistant beranimasi** sebagai pengganti pendekatan chatbot konvensional?
2. Bagaimana mengintegrasikan kecerdasan buatan ke dalam asisten virtual agar dapat memberikan informasi kampus Polibatam secara kontekstual dan relevan?
3. Bagaimana mengimplementasikan animasi interaktif (status berpikir, berbicara, idle, sukses, error) pada karakter asisten untuk meningkatkan pengalaman pengguna?
4. Bagaimana menguji fungsionalitas dan kelayakan aplikasi mobile POLA sebagai asisten informasi kampus?

---

## 3. Tujuan

### 3.1 Tujuan Umum

Membangun aplikasi mobile **POLA — Polibatam AI Assistant** yang menyediakan asisten virtual beranimasi untuk membantu civitas Polibatam mengakses informasi kampus secara interaktif.

### 3.2 Tujuan Khusus

1. Merancang antarmuka aplikasi mobile dengan karakter **AI Assistant animasi** sebagai elemen utama interaksi.
2. Mengimplementasikan modul asisten AI yang mampu memahami dan merespons pertanyaan seputar Polibatam.
3. Mengintegrasikan animasi status asisten (idle, listening, thinking, speaking, success, error) pada alur interaksi pengguna.
4. Menyediakan modul informasi kampus (akademik, beasiswa, magang, pengumuman, dan layanan lain) yang terhubung dengan AI Assistant.
5. Melakukan pengujian fungsional dan evaluasi pengalaman pengguna terhadap aplikasi yang dikembangkan.

---

## 4. Manfaat

### 4.1 Manfaat Teoritis

1. Memberikan kontribusi dalam penerapan AI Assistant beranimasi pada aplikasi mobile layanan kampus.
2. Menjadi referensi pengembangan asisten virtual interaktif di lingkungan pendidikan vokasi.

### 4.2 Manfaat Praktis

1. Memudahkan mahasiswa dan civitas Polibatam mendapatkan informasi kampus secara cepat.
2. Meningkatkan pengalaman pengguna melalui antarmuka visual yang lebih menarik dan interaktif dibanding chatbot teks biasa.
3. Menjadi prototype layanan digital kampus yang dapat dikembangkan lebih lanjut oleh Polibatam.

---

## 5. Ruang Lingkup

Ruang lingkup tugas akhir dibatasi pada:

1. **Platform:** Aplikasi mobile Android (dengan opsi build web untuk demonstrasi).
2. **Pengguna:** Mahasiswa dan civitas Politeknik Negeri Batam.
3. **Fitur utama:**
   - Karakter AI Assistant beranimasi (bukan chatbot berbasis bubble chat tradisional).
   - Interaksi tanya-jawab informasi kampus.
   - Modul informasi kampus terstruktur.
   - Riwayat interaksi dan personalisasi dasar.
4. **Teknologi rencana:**
   - Frontend: Flutter
   - Animasi: Lottie / Rive / Flutter Animation
   - Backend AI: Node.js + API Large Language Model (LLM)
   - Basis data & autentikasi: Supabase (opsional)
5. **Batasan:**
   - Informasi kampus bersumber dari knowledge base dan data yang tersedia secara terbuka/resmi.
   - Asisten difokuskan pada domain Polibatam, bukan pertanyaan umum di luar konteks kampus.
   - Tidak mencakup integrasi real-time penuh dengan seluruh sistem internal kampus (misalnya SIA) kecuali disediakan API resmi.

---

## 6. Perbedaan dengan Proyek PBL Sebelumnya

| Aspek | Proyek PBL (Sebelumnya) | Tugas Akhir (Rencana) |
|-------|-------------------------|------------------------|
| Judul | Implementasi Chatbot AI pada Aplikasi POLA Berbasis Mobile | Aplikasi Mobile POLA — Polibatam AI Assistant |
| Konsep utama | Chatbot percakapan berbasis teks | AI Assistant beranimasi |
| Interaksi | Bubble chat seperti messenger | Karakter asisten + animasi status + dialog interaktif |
| Fokus UX | Kecepatan jawaban | Pengalaman pendampingan visual |
| Inovasi TA | — | Animasi karakter, transisi emosi asisten, interaksi multimodal |

---

## 7. Metodologi Penelitian / Pengembangan

Metode yang digunakan adalah **Research and Development (RnD)** dengan tahapan:

1. **Studi literatur** — kajian AI Assistant, animasi UI mobile, dan layanan informasi kampus.
2. **Analisis kebutuhan** — wawancara/kuesioner singkat kepada mahasiswa (jika memungkinkan) dan observasi kebutuhan informasi kampus.
3. **Perancangan sistem** — use case, arsitektur, wireframe, desain karakter asisten, storyboard animasi.
4. **Implementasi** — pengembangan aplikasi Flutter, integrasi animasi, backend AI, modul informasi.
5. **Pengujian** — pengujian fungsional, pengujian antarmuka, evaluasi respons AI, UAT terbatas.
6. **Evaluasi & penyusunan laporan** — analisis hasil, kesimpulan, dan saran.

---

## 8. Rencana Tahapan Pengerjaan

| No | Tahapan | Kegiatan | Estimasi |
|:---:|---------|----------|----------|
| 1 | Proposal & studi literatur | Finalisasi judul, kajian pustaka, analisis kebutuhan | Bulan 1–2 |
| 2 | Analisis & perancangan | Wireframe, desain karakter asisten, arsitektur sistem | Bulan 2–3 |
| 3 | Implementasi frontend | UI mobile, animasi asisten, navigasi aplikasi | Bulan 3–5 |
| 4 | Implementasi backend AI | API asisten, knowledge base Polibatam | Bulan 4–5 |
| 5 | Integrasi & pengujian | Functional test, UI test, evaluasi asisten | Bulan 5–6 |
| 6 | Penyusunan laporan TA | Bab I–V, dokumentasi, sidang | Bulan 6–7 |

---

## 9. Desain Konsep AI Assistant (Ringkas)

Asisten POLA dirancang sebagai karakter virtual yang:

- **Menyambut pengguna** dengan animasi idle dan greeting.
- **Mendengarkan** pertanyaan (input teks/suara) dengan animasi *listening*.
- **Memproses** pertanyaan dengan animasi *thinking*.
- **Menyampaikan jawaban** dengan animasi *speaking* disertai teks respons.
- **Memberi umpan balik** sukses atau error secara visual bila layanan AI tidak tersedia.

Pendekatan ini menekankan pengalaman **assistant** yang mendampingi, bukan sekadar **chatbot** yang hanya menampilkan log percakapan.

---

## 10. Referensi (Draft)

1. Russell, S., & Norvig, P. (2020). *Artificial Intelligence: A Modern Approach*.
2. Flutter Documentation — Animation & Motion. https://docs.flutter.dev/ui/animation
3. Lottie Files Documentation. https://lottiefiles.com/
4. Rive Documentation. https://rive.app/docs
5. Politeknik Negeri Batam — Website resmi. https://polibatam.ac.id/
6. Supabase Documentation. https://supabase.com/docs

---

## 11. Penutup Draft

Draft proposal ini disusun sebagai dokumen pendukung pengajuan judul Tugas Akhir **"Aplikasi Mobile POLA — Polibatam AI Assistant"** dengan fokus pada pengembangan **asisten AI beranimasi** untuk layanan informasi kampus Polibatam. Dokumen ini dapat disesuaikan lebih lanjut sesuai format resmi Program Studi Teknik Informatika Politeknik Negeri Batam dan masukan dosen pembimbing.

---

**Polibatam, Juli 2026**

**Muhammad Nabil**  
NIM 3312411007
