# Naskah demonstrasi bagian Sastrawan

Gunakan data demo untuk rekaman. Tidak perlu masuk akun, menunjukkan email pribadi, atau mengaktifkan backend. Bagian CV, surat lamaran, data diri/identitas, dan Perjalanan karier tidak menjadi materi rekaman ini karena dibagi kepada anggota lain.

## Narasi yang bisa dibaca

“Saya menjelaskan bagian pencari kerja pada aplikasi LangkahKerja. Aplikasi ini menggunakan Flutter dan mengambil tema SDG 8, yaitu pekerjaan layak dan pertumbuhan ekonomi.

Pada Beranda terdapat ringkasan dan akses ke lowongan. Untuk demonstrasi ini saya menggunakan data simulasi yang diberi label, karena sumber lowongan Indonesia belum terhubung.

Di Eksplorasi, pengguna dapat mencari posisi atau perusahaan dan menyaring lowongan berdasarkan kategori, lokasi, tipe pekerjaan, tanggal, atau remote sesuai informasi yang tersedia. Pengguna juga dapat menyimpan pencarian yang sering dipakai.

Detail menampilkan perusahaan, lokasi, deskripsi, dan sumber. Lowongan dapat disimpan sebagai favorit. Jika tautan tersedia, aplikasi menampilkan alamat tujuan sebelum membuka browser. LangkahKerja tidak mengirim CV atau lamaran secara otomatis.

Pada menu Lamaran, pengguna dapat mencatat lowongan sendiri, memperbarui status, menulis catatan pribadi, dan mengatur agenda. Status ini diisi oleh pengguna sendiri, bukan diperbarui perusahaan. Jika ada catatan belum disimpan, aplikasi meminta pengguna memilih melanjutkan menulis atau mengabaikan perubahan sebelum keluar.

Ringkasan progres membantu membaca catatan yang sudah dibuat. Perbandingan favorit menunjukkan informasi lowongan dan kata kunci minat yang ditemukan. Bantuan dapat dibaca tanpa internet. Hasil perbandingan tidak merupakan penilaian kelayakan diterima kerja.

Pada layar lebih besar, navigasi berubah menjadi samping dan kartu dapat tersusun dalam dua kolom. Pada ponsel dan landscape pendek, aplikasi tetap memakai navigasi bawah. Ukuran teks besar tetap didukung dan perubahan ukuran layar tidak menghapus query atau favorit.

Fitur lokal sudah diuji dengan analyzer, widget test, dan build. Pengujian backend produksi serta perangkat nyata tetap merupakan tahap berikutnya. Demikian demonstrasi bagian pencari kerja yang saya kerjakan.”

## Shot list

| Urutan | Tampilan | Tindakan |
|---|---|---|
| 1 | Beranda | Tunjukkan mode pencari kerja dan label demo |
| 2 | Eksplorasi | Cari posisi, lalu lihat kategori/filter |
| 3 | Detail | Baca informasi, simpan favorit, pilih status |
| 4 | Lamaran | Buka catatan yang sudah ditambahkan |
| 5 | Catatan manual | Tambahkan posisi/perusahaan contoh dan simpan |
| 6 | Progres | Tunjukkan ringkasan; aktifkan demo hanya untuk contoh |
| 7 | Bandingkan | Pilih 2 favorit dan lihat data sumber |
| 8 | Bantuan | Cari kata “rekening” untuk panduan keamanan |
| 9 | Responsif | Bandingkan portrait dan desktop; navigasi dan kolom berubah |

## Catatan untuk editor kelompok

Video demonstrasi yang disertakan menampilkan layar aplikasi nyata dengan data simulasi, disusun per langkah, dan tanpa suara pribadi. Subtitle/narasi terpisah dapat dipakai untuk menambahkan voice-over. Potongan ini khusus bagian pencari kerja; jangan mengklaim demo sebagai feed produksi atau sebagai pengujian ponsel native.

Bagian employer, admin, CV, Perjalanan karier, dan data diri direkam anggota pemilik bagian masing-masing. Tidak ada pesan yang dikirim ke grup secara otomatis.
