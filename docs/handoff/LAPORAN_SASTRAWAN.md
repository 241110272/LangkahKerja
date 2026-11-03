# Kontribusi Sastrawan pada LangkahKerja

Bagian laporan untuk digabungkan dengan laporan kelompok. Mata kuliah: Mobile Front End. Tanggal penyusunan: 3 November 2026. Lengkapi identitas akademik, format kampus, dan materi pertemuan dari dokumen kelas sebelum pengumpulan.

## Latar belakang dan tujuan

LangkahKerja adalah prototipe aplikasi Flutter bertema SDG 8, Decent Work and Economic Growth. Bagian pencari kerja membantu pengguna menelusuri informasi lowongan dan mencatat proses melamar secara teratur. Hubungannya dengan SDG 8 adalah mendukung akses informasi pekerjaan serta persiapan pencarian kerja. Aplikasi tidak menjamin penerimaan atau menilai kelayakan seseorang secara otomatis.

## Ruang lingkup kontribusi

Kontribusi Sastrawan meliputi antarmuka pencari kerja, pencarian/filter, detail lowongan, favorit, pencatatan lamaran manual, status dan catatan pribadi, agenda, preferensi, cadangan/pemulihan, materi persiapan, serta penyempurnaan progres, perbandingan favorit, dan bantuan offline. Integrasi akun dan backend disiapkan dalam bentuk kode dan dokumentasi, belum layanan produksi.

Update kelompok pada `origin/main` sampai commit `8780dc0` dipadukan dengan pengembangan lokal versi 1.2. Mode pemberi kerja dan admin, generator CV/surat, pasfoto, identitas, dan Perjalanan karier tetap merupakan bagian kontribusi tim. Berkas `career_tools.dart`, `career_journey.dart`, `employer.dart`, dan `admin.dart` dipertahankan tanpa perubahan fitur pada pekerjaan responsif ini.

## Implementasi tampilan responsif

Sebelumnya, layar besar tetap menampilkan bingkai ponsel dengan lebar 430 piksel. Ruang kerja pencari kerja sekarang dapat memakai lebar yang tersedia hingga 1180 piksel. Mode lain tetap mempertahankan presentasi mobile milik tim.

| Kondisi | Perilaku |
|---|---|
| Layar sempit | Navigasi bawah, kartu satu kolom, konten dapat digulir |
| Lebar ruang kerja minimal 760 dan tinggi minimal 520 piksel | Navigasi samping dengan tiga tujuan: Beranda, Eksplorasi, Lamaran |
| Ruang kartu cukup lebar | Dua kolom dengan `Wrap`; tinggi kartu mengikuti isi |
| Ukuran teks besar | Kolom menyesuaikan kebutuhan teks; isi tidak diperkecil untuk memaksakan tata letak |
| Landscape pendek | Navigasi bawah tetap dipakai; konten vertikal dapat digulir |
| Perubahan ukuran jendela | Query pencarian dan data favorit tetap dipertahankan |

`LayoutBuilder` membaca batas ruang yang benar-benar tersedia. `MediaQuery` membaca ukuran dan skala teks pengguna. `Expanded` membagi ruang navigasi/konten, sedangkan `Wrap` menyusun kartu tanpa tinggi tetap. Header menyesuaikan ruang logo dan banner mengikuti tinggi teks agar tidak terpotong. Form pencatatan manual menutup keyboard ketika pengguna menggulir.

Berkas utama:

- `lib/widgets/adaptive_viewport.dart`: batas ruang aplikasi dan penyesuaian bingkai.
- `lib/screens/app.dart`: pilihan navigasi bawah/samping dan integrasi halaman.
- `lib/widgets/responsive_jobs.dart`: kolom kartu yang mengikuti ruang dan teks.
- `lib/widgets/career_banner.dart`: banner dengan tinggi minimum serta isi yang dapat bertambah.
- `test/responsive_test.dart`: matriks layar serta pemeliharaan state saat resize.

## Alur pencari kerja

Pengguna memilih mode Hiree, membuka demo ketika sumber belum terhubung, mencari dan memfilter lowongan, membaca detail, serta menyimpan favorit. Pengguna juga dapat menambahkan lamaran dari luar aplikasi. Status diisi sendiri dari Ingin dilamar, Sudah dilamar, Interview, Diterima, atau Ditolak. Catatan dan agenda membantu mengingat langkah berikutnya.

Ringkasan progres menghitung catatan yang tersedia; data demo dikecualikan secara default. Perbandingan menampilkan data 2–3 favorit serta kata kunci yang ditemukan pada teks lowongan. Pusat bantuan tersedia lokal dan dapat dicari. Tidak ada prediksi peluang diterima atau pengiriman CV otomatis.

## Pengujian dan hasil

Rincian hasil akhir, ukuran layar, dan batas bukti tersedia pada [VALIDASI.md](VALIDASI.md). Tes mencakup portrait 320/390 piksel, landscape 844×390, tablet 1024×768, desktop 1440×900, serta teks 2× pada ponsel dan tablet. Pengujian memastikan tidak ada overflow pada alur utama, navigasi berubah sesuai ruang, dan query/favorit tidak hilang ketika layar berubah ukuran.

Hasil build web dan APK debug harus dibedakan dari pengujian perangkat nyata. Keberhasilan build tidak membuktikan notifikasi native, distribusi toko, atau layanan backend produksi.

## Batas implementasi

- Feed lowongan menggunakan data demo berlabel ketika sumber Indonesia belum terhubung.
- Akun, OTP/SMTP, sinkronisasi produksi, dan penghapusan akun cloud masih memerlukan konfigurasi dan uji nyata.
- Mode admin/employer adalah prototipe UI. Pemilihan mode tidak merupakan sistem otorisasi server.
- Pengingat native belum diuji pada ponsel fisik dalam pekerjaan ini.
- Pengujian iOS dan penandatanganan rilis memerlukan lingkungan serta akun pengembang yang sesuai.

## Kesimpulan

Bagian pencari kerja menggabungkan penelusuran lowongan dan pencatatan proses melamar dalam antarmuka Flutter. Penyempurnaan responsif membuat ruang kerja menggunakan layar ponsel, landscape, tablet, dan desktop dengan lebih sesuai, sambil mempertahankan kontribusi fitur anggota lain.

Sumber implementasi: repository [241110272/benevolent](https://github.com/241110272/benevolent), kode pada branch integrasi, dan hasil pengujian lokal yang dicatat dalam dokumen validasi.
