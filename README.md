# LangkahKerja

**Versi kandidat 1.2.0+3** · Flutter · SDG 8 · Pengembang **Benelovent**


LangkahKerja membantu pencari kerja di Indonesia menemukan peluang dan mengelola proses melamar. Antarmuka memakai tema plum–lavender, font Manrope, dan aset lokal.

## Jalankan

Gunakan Flutter **3.47.7**. Untuk menjalankan di Android, siapkan JDK 21 dan Android SDK platform 36.

```powershell
flutter pub get
flutter run -d chrome
# Opsional: konfigurasi Supabase sesuai docs/BACKEND_SETUP.md, lalu:
flutter run --dart-define-from-file=config/env.json
```

## Fitur

- Onboarding dan kebijakan privasi berbahasa Indonesia.
- Feed Indonesia dari backend, cache offline, refresh, pagination, pencarian, kategori, filter kota/tipe/tanggal/remote/preferensi, dan urutan tanggal.
- Favorit, riwayat pencarian, serta kombinasi pencarian tersimpan.
- Detail lowongan, sumber, gaji bila tersedia, tautan lamaran asli, berbagi, dan pelaporan masalah.
- Lamaran manual dari sumber di luar aplikasi; status, catatan pribadi, riwayat perubahan, dan agenda follow-up.
- Ringkasan progres dengan rentang waktu, distribusi status, agenda aktif, serta aktivitas terbaru; data demo terpisah secara default.
- Bandingkan 2–3 favorit: lokasi, pola kerja, tipe, gaji dari sumber, dan kata kunci minat yang ditemukan.
- Pusat bantuan offline yang bisa dicari, kontak dukungan, konfirmasi alamat situs luar, dan perlindungan catatan yang belum disimpan.
- Pengingat lokal opsional pada Android/iOS. Browser hanya menampilkan agenda.
- Login/daftar lewat kode email, sesi aman di perangkat mobile, sinkronisasi revisi, pemisahan akun, dan penyelesaian konflik.
- Ekspor cadangan JSON, pemulihan tervalidasi, ekspor CSV, penghapusan data/cache, dan penghapusan akun.
- Checklist persiapan serta materi CV, portofolio, interview, dan keamanan lowongan.
- Ikon aplikasi, konfigurasi signing rilis, CI, skema SQL/RLS, Edge Functions, halaman privasi/penghapusan publik, dan draf listing Play Store.


- Mode Hiree, Hirer, dan Admin dari kontribusi tim; moderasi admin masih memakai data dummy.
- Alat CV, surat lamaran, pasfoto, identitas opsional, dan Perjalanan karier tetap tersedia di hamburger.

## Status backend dan data

Supabase client, migrasi, dan panduannya tersedia, tetapi belum dikonfigurasi atau diterapkan ke proyek. Tanpa konfigurasi, gunakan data demo yang sudah diberi label; data tersebut bukan lowongan aktif. Feed produksi memerlukan sumber lowongan berizin. Draf CV/surat hanya sementara, foto diproses di perangkat, dan berkas identitas tidak disimpan atau diunggah aplikasi.

## Dokumen penting

- [Setup backend, akun, dan sumber Indonesia](docs/BACKEND_SETUP.md)
- [Gerbang rilis, signing, dan Play Console](docs/RELEASE.md)
- [Persiapan App Store dan standar lintas toko](docs/APP_STORE.md)
- [APK debug dan pengujian Android](docs/ANDROID_TESTING.md)
- [Bukti dan batas validasi kandidat 1.2.0](docs/VALIDATION_1.2.md)
- [Draf materi Play Store](docs/store/LISTING.md)
- [Kebijakan privasi publik](docs/legal/privacy.html)
- [Halaman penghapusan akun publik](docs/legal/delete-account.html)
- [Aset foto/font dan prompt](assets/README.md)

Lamaran dilakukan di situs sumber dan statusnya diperbarui oleh pengguna. LangkahKerja tidak mengirim CV otomatis atau menjamin verifikasi independen atas setiap lowongan.

## Pengujian

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --no-wasm-dry-run
```

Pengujian SQL lokal memakai PostgreSQL/WASM dan tidak menyentuh proyek Supabase:

```powershell
npm install --prefix .tools/backend-tests @electric-sql/pglite@0.5.10
node scripts/backend_test.mjs
```

Ini memeriksa pembatasan feed publik, isolasi data per akun, revisi konflik, kuota laporan, dan cascade penghapusan akun. Uji email OTP, perangkat Android/iOS, sinkronisasi dua perangkat, serta notifikasi native tetap harus dijalankan pada konfigurasi nyata sebelum rilis.

## Mencoba alur lokal

1. Selesaikan onboarding, buka Eksplorasi, dan pilih **Coba mode demo** atau **Gunakan demo** saat sumber belum terhubung.
2. Cari posisi, coba kategori/filter, dan simpan pencarian.
3. Buka detail, simpan favorit, pilih status, tulis catatan lalu **Simpan catatan**.
4. Tambahkan agenda. Pada Android/iOS, aktifkan notifikasi jika diinginkan.
5. Di Lamaran, pilih **Catat lowongan sendiri** untuk peluang dari luar aplikasi.
6. Buka hamburger untuk Peluang, alat berkas karier, Perjalanan karier, atau Profil & preferensi.
7. Ekspor cadangan, muat ulang aplikasi, dan periksa pemulihan data.

## Struktur

```text
lib/models/       Model lowongan, status, riwayat, pencarian tersimpan
lib/services/     SQLite/prefs, API, cloud sync, ekspor, notifikasi
lib/screens/      Beranda, peluang, lamaran, alat karier, akun, privasi
lib/widgets/      Komponen tema bersama
supabase/         Migrasi RLS dan Edge Functions (belum dideploy)
docs/             Panduan rilis, backend, legal, dan listing
scripts/          Validasi rilis, ikon, legal, dan tes SQL
test/             Pengujian logika, keamanan, cloud mock, dan alur UI
```

Lisensi aplikasi: [GPL-3.0](LICENSE). Lisensi Manrope: `assets/fonts/OFL-Manrope.txt`.
