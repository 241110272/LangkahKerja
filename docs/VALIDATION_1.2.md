# Validasi kandidat 1.2.0+3

Tanggal: **23 Oktober 2026**, checkout lokal Windows. Pengembang: Benelovent.

## Hasil Flutter dan web

- Resolusi dependency offline berhasil; tidak menambah paket atau SDK pihak ketiga.
- Format kode diperiksa dan analyzer melaporkan **No issues found**.
- Seluruh **32 tes Flutter lulus**, termasuk delapan tes baru untuk perhitungan progres, batas waktu, kata kunci, perbandingan, bantuan, konfirmasi tautan, draf catatan, dan layar 320px pada skala teks 2×.
- Tes pergantian akun diperluas: halaman pribadi tetap ditutup saat ada draf catatan yang belum disimpan.
- Build web `--no-pub --no-wasm-dry-run` berhasil dalam 104,2 detik.
- Pratinjau hasil build diperiksa pada browser lokal: menu Profil, halaman progres, pencarian bantuan “rekening”, serta pembukaan jawaban keamanan berfungsi. Pemeriksaan ini menggunakan penyimpanan browser lokal yang sudah ada dan tidak menghubungkan backend produksi.

CLI dijalankan memakai Dart SDK terpasang dan `flutter_tools.snapshot` di `C:/Users/sastr/.codex/tools/flutter/bin/cache/`; perintah Flutter yang dijalankan adalah `pub get --offline`, `analyze --no-pub`, `test --no-pub`, dan build di atas. Pengujian menggunakan Flutter 3.47.7 / Dart 3.13.5.

## Android

- Build APK debug `--no-pub` berhasil dalam 170,4 detik.
- `scripts/check_android_apk.ps1` lulus: tanda tangan v2 valid, ZIP alignment 16 KB, serta pemeriksaan ELF/RELRO pada tujuh pustaka 64 bit.
- Metadata APK: `id.benelovent.langkahkerja`, versi `1.2.0`, versionCode `3`, minSdk 24, targetSdk 36; ABI arm64-v8a, armeabi-v7a, dan x86_64.
- Artefak: `build/app/outputs/flutter-apk/app-debug.apk`, 171.681.596 byte (sekitar 163,7 MiB), debug signing untuk pengujian.

SHA-256:

```text
268ecb44f8c2395f28bc8a718e1d8a03b9f6401a918f7f753cab70fb1b707501
```

Build masih memberikan peringatan kompatibilitas SDK XML v3/v4. Ini tidak menggagalkan build; pembaruan toolchain berikutnya tetap perlu divalidasi. Laporan [versi 1.1.0](VALIDATION.md) adalah bukti historis dan tidak boleh digunakan sebagai hash APK versi 1.2.0.

## Batas verifikasi

Belum diuji pada Android/iPhone fisik atau emulator. Tidak membangun/menandatangani iOS pada Windows. Belum membuat AAB bertanda tangan upload key, menjalankan TestFlight, atau mengajukan review toko.

Backend Supabase, feed Indonesia berizin, SMTP/OTP, penghapusan akun produksi, sinkronisasi dua perangkat, serta URL legal publik tetap memerlukan konfigurasi dan pengujian nyata. Pengujian sesi menggunakan controller/HTTP tiruan, bukan akun produksi. Tidak ada schema atau deployment backend yang diubah.

Checklist lintas toko dan iOS: [APP_STORE.md](APP_STORE.md). Skenario perangkat: [ANDROID_TESTING.md](ANDROID_TESTING.md).
