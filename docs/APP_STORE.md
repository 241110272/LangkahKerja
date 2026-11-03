# Persiapan App Store dan standar lintas toko

Diperiksa pada 23 Oktober 2026. Dokumen ini adalah gerbang verifikasi, bukan pernyataan bahwa aplikasi sudah disetujui Apple atau Google.

## Perubahan kandidat 1.2.0+3

- Progres lamaran: rentang semua waktu/7/30 hari berdasarkan riwayat pencatatan paling awal yang masih tersedia, status saat ini, aktivitas, dan agenda lamaran aktif. Data demo tidak masuk hitungan kecuali dipilih.
- Perbandingan 2–3 favorit: data sumber, lokasi, remote, tipe, gaji apa adanya, dan penjelasan kata kunci minat. Tidak memberikan skor kelayakan atau peluang diterima.
- Pusat bantuan lokal yang bisa dicari, dengan penjelasan offline, sinkronisasi, ekspor/pemulihan, penghapusan, notifikasi, dan keamanan pencarian kerja. Email hanya dibuka atas tindakan pengguna.
- Konfirmasi domain serta URL lengkap sebelum membuka tautan HTTPS dari lowongan/deskripsi. Situs luar memiliki pengelola dan kebijakan sendiri; HTTPS tidak memverifikasi perusahaan.
- Konfirmasi saat meninggalkan detail yang mempunyai perubahan catatan belum disimpan. Pergantian akun tetap membersihkan halaman pribadi, termasuk draf.

Tidak ada permission, SDK analitik, pelacak iklan, pembayaran, atau pengumpulan data baru untuk fitur ini. Ringkasan dan perbandingan dihitung di perangkat dari data yang sudah ada. Pilihan perbandingan tidak disimpan atau disinkronkan.

## Kualitas dan kelengkapan sebelum submit

| Area | Implementasi/kondisi | Bukti yang masih wajib |
| --- | --- | --- |
| Fungsi utama | Penelusuran, favorit, pencatatan manual, agenda, bantuan, ekspor tersedia | Feed Indonesia produksi yang berguna dan hak penggunaan datanya |
| Akun | UI OTP, sinkronisasi, konflik, penghapusan sudah disiapkan | Backend aktif, email terkirim, OTP, penghapusan serta dua perangkat diuji secara nyata |
| Mode tanpa akun | Fitur lokal tersedia | Uji pemasangan baru, offline, proses dimatikan, dan pemulihan |
| Privasi | Kebijakan dalam aplikasi, draf halaman publik, kontrol ekspor/hapus | URL HTTPS publik benar-benar berfungsi; retensi/log sesuai konfigurasi produksi |
| Dukungan | FAQ offline, alamat sastraxez@gmail.com dapat disalin | Email dipantau; Support URL publik dengan kontak pengembang |
| Aksesibilitas | Teks mengikuti sistem, indikator progres berlabel, tata letak dapat digulir | VoiceOver/TalkBack, kontras, keyboard, orientasi, dan perangkat fisik |
| Deskripsi toko | Demo jelas; status manual; tidak mengklaim mengirim CV | Screenshot dari aplikasi nyata dan informasi listing yang sesuai build yang dikirim |
| Penilaian konten | Tidak ada chat/feed kiriman publik dari pengguna | Isi kuesioner umur, iklan, dan Data safety/App Privacy sesuai konfigurasi akhir |

## Jalur iOS — harus dilakukan pada Mac

1. Tentukan bundle identifier iOS milik tim sebelum terbit. Proyek masih menggunakan identifier awal `id.ac.langkahkerja.langkahKerja`; identifier Android adalah `id.benelovent.langkahkerja`. Jangan mengganti identitas aplikasi yang sudah pernah diterbitkan.
2. Konfigurasikan Apple Developer team, sertifikat, provisioning, deployment target, dan App Store Connect. Gunakan nomor build yang belum pernah diunggah.
3. Jalankan dependency resolution, analyzer, tes, build iOS dan archive pada versi Xcode yang diterima App Store Connect saat pengunggahan. Lingkungan Windows tidak dapat memberikan bukti kompilasi/penandatanganan iOS.
4. Periksa privacy report archive Xcode: manifest privacy dari seluruh plugin, required-reason APIs, signature SDK yang diwajibkan Apple, data yang diakses, dan deklarasi App Privacy. Jangan menyalin alasan akses API yang tidak digunakan atau menganggap manifest plugin sudah cukup tanpa melihat archive.
5. Uji izin notifikasi yang baru diminta setelah persetujuan pengguna, jadwal lokal, foreground/background, klik notifikasi saat cold start, batas jumlah pengingat, serta perilaku sesudah login/logout dan pemulihan cadangan.
6. Uji share sheet pada iPhone/iPad, pemilihan berkas JSON, penyimpanan sesi Keychain, tautan browser/mail, keyboard, safe area, rotasi, ukuran teks besar, dan VoiceOver. Sertakan pengujian catatan belum disimpan dengan tombol kembali/swipe gesture.
7. Lengkapi Privacy Policy URL, Support URL, informasi kontak, App Privacy, content rating, deskripsi, screenshot tiap ukuran yang diwajibkan, serta deklarasi enkripsi berdasarkan penggunaan sebenarnya.
8. Untuk review, sediakan backend yang hidup, instruksi pengujian, dan akses reviewer yang dapat digunakan. Jangan mengirim build yang hanya mempunyai feed kosong atau simulasi sebagai pengganti layanan produksi.
9. Distribusikan melalui TestFlight dan selesaikan masalah crash/akses/UX sebelum mengajukan review.

## Jalur Android

Lihat [RELEASE.md](RELEASE.md) dan [ANDROID_TESTING.md](ANDROID_TESTING.md). APK debug adalah artefak uji; upload Play Store memerlukan AAB bertanda tangan upload key. Build sukses dan inspeksi statis tidak membuktikan perilaku perangkat atau kelulusan review.

## Sumber primer

- [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/): kelengkapan 2.1, fungsi minimum 4.2, dan privasi 5.1.
- [Apple: menawarkan penghapusan akun dalam aplikasi](https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion/).
- [Apple: privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files).
- [Google Play: persyaratan penghapusan akun](https://support.google.com/googleplay/android-developer/answer/13327111).

Aktivasi backend tetap ditunda sesuai keputusan pemilik. Tidak ada pengajuan toko, pembuatan akun berbayar, deployment, atau publikasi yang dilakukan dalam perubahan ini.
