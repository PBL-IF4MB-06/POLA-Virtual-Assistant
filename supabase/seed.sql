-- Seed data POLA (jalankan SETELAH migration, di SQL Editor Supabase)
-- Ganti email admin di bawah sesuai akun Supabase Auth Anda.

-- Contoh FAQ awal (tanpa created_by — bisa diisi setelah admin login)
insert into public.kb_entries (question, answer, is_published)
values
  (
    'Apa itu POLA?',
    'POLA (Polibatam Assistant) adalah asisten virtual resmi untuk Politeknik Negeri Batam. POLA membantu menjawab pertanyaan seputar akademik, jurusan, beasiswa, laboratorium, magang, dan layanan kampus.',
    true
  ),
  (
    'Bagaimana cara menggunakan chat POLA?',
    'Buka menu Chat atau Copilot, ketik pertanyaan Anda dalam Bahasa Indonesia, lalu kirim. POLA akan menjawab berdasarkan basis pengetahuan internal dan AI backend.',
    true
  ),
  (
    'Siapa yang bisa mengakses panel admin?',
    'Hanya pengguna dengan role admin yang dapat mengelola FAQ, knowledge base, dan memberikan akses admin kepada pengguna lain.',
    true
  )
on conflict do nothing;

-- Untuk menjadikan user pertama sebagai admin, jalankan SETELAH mendaftar:
-- update public.profiles set role = 'admin' where email = 'admin@polibatam.ac.id';
