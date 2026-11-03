import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';
import '../main.dart';

const helpArticles = <({String question, String answer})>[
  (
    question: 'Apakah membuka tautan berarti sudah melamar?',
    answer:
        'Belum. Selesaikan lamaran pada situs perusahaan atau penyedia lowongan. Setelah itu ubah status menjadi Sudah dilamar secara manual. LangkahKerja tidak mengirim CV atau memberikan keputusan penerimaan.',
  ),
  (
    question: 'Mengapa lowongan belum muncul?',
    answer:
        'Feed Indonesia membutuhkan sumber yang sudah dihubungkan oleh pengembang. Periksa koneksi, lalu coba muat ulang pada Eksplorasi. Mode demo berisi simulasi yang berlabel, bukan lowongan aktif. Kamu tetap dapat mencatat lamaran sendiri dari tab Lamaran.',
  ),
  (
    question: 'Bisakah aplikasi dipakai tanpa akun dan internet?',
    answer:
        'Bisa. Favorit yang telah disimpan, catatan lamaran, agenda, materi karier, dan bantuan tersedia di perangkat. Pencarian feed baru, login, dan sinkronisasi memerlukan internet. Detail tersimpan bisa sudah kedaluwarsa; periksa status di situs sumber.',
  ),
  (
    question: 'Mengapa data berbeda di perangkat lain?',
    answer:
        'Masuk dengan akun yang sama di Akun & sinkronisasi, lalu sinkronkan. Jika ada konflik, periksa pilihan data sebelum mengganti. Buat cadangan dari Data & privasi terlebih dahulu. Jika backend belum dikonfigurasi, sinkronisasi belum tersedia.',
  ),
  (
    question: 'Mengapa pengingat tidak berbunyi?',
    answer:
        'Pengingat diaktifkan pada detail lamaran dan berlaku per perangkat. Beri izin notifikasi di pengaturan sistem dan periksa penghemat baterai. Jadwal dapat tertunda oleh sistem. Browser hanya menampilkan agenda. Setelah pemulihan atau sinkronisasi, aktifkan kembali pengingat pada perangkat tujuan.',
  ),
  (
    question: 'Bagaimana mencadangkan atau memindahkan catatan?',
    answer:
        'Buka Profil → Data & privasi → ekspor cadangan JSON. Simpan di tempat yang kamu kendalikan. Untuk memulihkan, pilih berkas cadangan pada halaman yang sama; periksa konfirmasi karena data dapat terganti. CSV berguna untuk dibaca di spreadsheet, bukan untuk pemulihan. Berkas berisi data pribadi; bagikan hanya kepada pihak yang kamu percaya.',
  ),
  (
    question: 'Bagaimana menghapus data dan akun?',
    answer:
        'Data lokal dapat dihapus dari Profil → Data & privasi. Penghapusan lokal tidak otomatis menghapus akun atau data cloud. Untuk menghapus akun beserta data cloud, gunakan Hapus akun di halaman tersebut saat sudah masuk; autentikasi ulang mungkin diperlukan. Cadangan yang kamu ekspor harus dihapus sendiri dari tempat penyimpanannya.',
  ),
  (
    question: 'Bagaimana mengenali lowongan mencurigakan?',
    answer:
        'Waspadai permintaan transfer uang, OTP, password, atau akses rekening; desakan bertindak cepat; dan identitas perekrut yang tidak dapat dikonfirmasi. Cek domain tujuan dan hubungi perusahaan melalui kanal resmi yang kamu cari secara terpisah. HTTPS hanya melindungi koneksi, bukan bukti perusahaan tepercaya. Gunakan Laporkan lowongan bermasalah pada detail bila tersedia.',
  ),
  (
    question: 'Apakah perbandingan minat menilai kelayakan kerja?',
    answer:
        'Tidak. Perbandingan hanya menunjukkan kata kunci minat yang ditemukan pada teks lowongan. Informasi yang tidak tersedia ditulis Tidak disebutkan. Tidak ada penilaian otomatis tentang kemampuan atau peluang diterima.',
  ),
];

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});
  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final articles = helpArticles
        .where(
          (a) => '${a.question} ${a.answer}'.toLowerCase().contains(
            query.toLowerCase().trim(),
          ),
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'Ada yang bisa\nkami bantu?',
            style: TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Panduan ini dapat dibaca tanpa internet.',
            style: TextStyle(color: muted),
          ),
          const SizedBox(height: 20),
          TextField(
            maxLength: 100,
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Cari bantuan',
              counterText: '',
            ),
          ),
          const SizedBox(height: 14),
          if (articles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Belum ada jawaban yang cocok. Coba kata lain atau hubungi pengembang.',
              ),
            ),
          for (final article in articles)
            ExpansionTile(
              key: ValueKey(article.question),
              tilePadding: EdgeInsets.zero,
              title: Text(
                article.question,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      article.answer,
                      style: const TextStyle(height: 1.7),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 24),
          const Text(
            'Hubungi Benelovent',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const SelectableText(AppConfig.supportEmail),
          const SizedBox(height: 8),
          const Text(
            'Ceritakan langkah dan pesan kesalahan yang muncul. Jangan kirim password, kode OTP, isi cadangan, atau informasi rekening.',
            style: TextStyle(color: muted, height: 1.6),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Tulis email'),
                onPressed: () async {
                  try {
                    final opened = await launchUrl(
                      Uri(
                        scheme: 'mailto',
                        path: AppConfig.supportEmail,
                        queryParameters: {'subject': 'Bantuan LangkahKerja'},
                      ),
                    );
                    if (opened) return;
                  } catch (_) {
                    /* The address remains selectable on this screen. */
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Aplikasi email tidak tersedia. Salin alamat untuk menghubungi kami.',
                        ),
                      ),
                    );
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Salin email'),
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: AppConfig.supportEmail),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alamat email disalin.')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
