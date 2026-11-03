import 'package:flutter/material.dart';
import '../main.dart';
import '../models/application_insights.dart';
import '../services/job_store.dart';
import 'detail.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key, required this.store});
  final JobStore store;
  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final selected = <String>{};
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final ids = selected.where(store.saved.containsKey).toSet();
      return Scaffold(
        appBar: AppBar(title: const Text('Bandingkan lowongan')),
        body: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Pilih peluang\nyang cocok untukmu.',
              style: TextStyle(
                fontSize: 30,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih 2–3 favorit untuk membandingkan informasi dari sumber. Tidak ada peringkat atau jaminan kecocokan.',
              style: TextStyle(color: muted, height: 1.6),
            ),
            const SizedBox(height: 16),
            if (store.saved.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada favorit. Simpan lowongan dengan tombol bookmark terlebih dahulu.',
                  ),
                ),
              ),
            for (final job in store.saved.values)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(job.title),
                subtitle: Text('${job.company}${job.demo ? ' · Demo' : ''}'),
                value: ids.contains(job.id),
                onChanged: !ids.contains(job.id) && ids.length >= 3
                    ? null
                    : (v) => setState(() {
                        selected.removeWhere(
                          (id) => !store.saved.containsKey(id),
                        );
                        if (v == true) {
                          selected.add(job.id);
                        } else {
                          selected.remove(job.id);
                        }
                      }),
              ),
            if (store.saved.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${ids.length}/3 dipilih${ids.length < 2 ? ' · Pilih minimal 2 lowongan' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            if (ids.length >= 2) ...[
              const Divider(),
              const Text(
                'Ringkasan perbandingan',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              for (final id in ids)
                Builder(
                  builder: (context) {
                    final job = store.saved[id]!;
                    final words = matchingKeywords(job, store.skills);
                    return Card(
                      key: ValueKey('compare-$id'),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${job.company}${job.demo ? ' · Data demo' : ''}',
                            ),
                            const Divider(height: 28),
                            _field('Lokasi', job.location),
                            _field(
                              'Pola kerja',
                              job.remote
                                  ? 'Remote; cek batas lokasi di sumber'
                                  : 'Remote tidak disebutkan',
                            ),
                            _field(
                              'Tipe pekerjaan',
                              job.jobTypes.isEmpty
                                  ? 'Tidak disebutkan'
                                  : job.jobTypes.join(', '),
                            ),
                            _field(
                              'Gaji dari sumber',
                              job.salary ?? 'Tidak disebutkan',
                            ),
                            _field(
                              'Kata kunci minat',
                              store.skills.trim().isEmpty
                                  ? 'Isi minat di Profil untuk melihat kata yang ditemukan.'
                                  : words.isEmpty
                                  ? 'Tidak ditemukan pada data yang tersedia.'
                                  : words.join(', '),
                            ),
                            _field(
                              'Sumber',
                              job.demo ? 'Data simulasi' : job.source,
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      JobDetail(job: job, store: store),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Baca detail'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const Text(
                'Kata kunci dicari pada judul, deskripsi, dan tag. Gaji ditampilkan apa adanya; periode, mata uang, serta tunjangan perlu diperiksa pada sumber.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.7),
              ),
            ],
          ],
        ),
      );
    },
  );

  Widget _field(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 3),
        Text(value),
      ],
    ),
  );
}
