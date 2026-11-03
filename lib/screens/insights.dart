import 'package:flutter/material.dart';
import '../main.dart';
import '../models/application_insights.dart';
import '../models/job.dart';
import '../services/job_store.dart';
import 'agenda.dart';
import 'detail.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key, required this.store});
  final JobStore store;
  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  int days = 0;
  bool includeDemo = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final store = widget.store;
      final stats = ApplicationInsights(
        applications: store.applications,
        jobs: store.applicationJobs,
        timeline: store.timeline,
        followUps: store.followUps,
        now: DateTime.now(),
        days: days,
        includeDemo: includeDemo,
      );
      return Scaffold(
        appBar: AppBar(title: const Text('Progres lamaran')),
        body: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Lihat sejauh mana\nkamu melangkah.',
              style: TextStyle(
                fontSize: 30,
                height: 1.15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ringkasan dari catatan yang kamu isi sendiri. Rentang waktu memakai riwayat pencatatan paling awal yang masih tersedia.',
              style: TextStyle(color: muted, height: 1.6),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              children: [
                for (final value in [0, 7, 30])
                  ChoiceChip(
                    label: Text(value == 0 ? 'Semua waktu' : '$value hari'),
                    selected: days == value,
                    onSelected: (_) => setState(() => days = value),
                  ),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sertakan data demo'),
              value: includeDemo,
              onChanged: (v) => setState(() => includeDemo = v),
            ),
            Card(
              color: lavender,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.total} lamaran tercatat',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.active} masih dalam proses · ${stats.counts[ApplicationStatus.accepted]} diterima',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (stats.total == 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Belum ada catatan pada pilihan ini. Tambahkan lamaran di tab Lamaran, perluas rentang waktu, atau sertakan data demo.',
                  style: TextStyle(color: muted, height: 1.7),
                ),
              ),
            for (final status in ApplicationStatus.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Semantics(
                  label:
                      '${status.label}: ${stats.counts[status]} dari ${stats.total} lamaran',
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(status.label)),
                            Text(
                              '${stats.counts[status]}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: stats.total == 0
                              ? 0
                              : stats.counts[status]! / stats.total,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: lavender,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.event_note_outlined),
                title: Text(
                  '${stats.overdue} agenda lewat · ${stats.upcoming} mendatang',
                ),
                subtitle: const Text(
                  'Lamaran aktif dalam pilihan ini; agenda mendatang hingga 6 hari setelah hari ini.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AgendaPage(store: store),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aktivitas terbaru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (stats.activity.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Riwayat perubahan belum tersedia.',
                  style: TextStyle(color: muted),
                ),
              ),
            for (final event in stats.activity.take(20))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(event.job.title),
                subtitle: Text(
                  '${event.job.company}\n${event.change.status.label} · ${formatDateTime(context, event.change.at)}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => JobDetail(job: event.job, store: store),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Angka ini bukan peluang diterima atau penilaian kinerjamu. Catatan lama tanpa riwayat hanya muncul pada Semua waktu.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.7),
            ),
          ],
        ),
      );
    },
  );
}
