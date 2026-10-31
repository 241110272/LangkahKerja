import 'package:flutter/material.dart';

import '../main.dart';
import '../models/job.dart';
import '../models/user_data.dart';
import '../services/job_store.dart';
import 'agenda.dart';
import 'career_guide.dart';
import 'detail.dart';
import 'manual_application.dart';

class CareerJourney extends StatelessWidget {
  const CareerJourney({super.key, required this.store});
  final JobStore store;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final checklistCount = store.completedChecklist
          .intersection(careerChecklist.keys.toSet())
          .length;
      final agenda = store.followUps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final activity = <({String id, StatusChange change})>[
        for (final entry in store.timeline.entries)
          for (final change in entry.value) (id: entry.key, change: change),
      ]..sort((a, b) => b.change.at.compareTo(a.change.at));

      return Scaffold(
        appBar: AppBar(title: const Text('Perjalanan karier')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
          children: [
            Text(
              store.name.isEmpty
                  ? 'Ruang untuk bertumbuh.'
                  : 'Hai, ${store.name}.',
              style: const TextStyle(fontSize: 13, color: muted),
            ),
            const SizedBox(height: 5),
            const Text(
              'Setiap langkah\nberarti.',
              style: TextStyle(
                fontSize: 36,
                height: 1.08,
                letterSpacing: -1.8,
                fontWeight: FontWeight.w800,
                color: ink,
              ),
            ),
            const SizedBox(height: 20),
            _overviewCard(
              applications: store.applications.length,
              interviews: store.applications.values
                  .where((status) => status == ApplicationStatus.interview)
                  .length,
              saved: store.saved.length,
            ),
            const SizedBox(height: 24),
            _sectionTitle('Langkah berikutnya', 'Satu hal kecil sudah cukup.'),
            const SizedBox(height: 11),
            _nextStep(context, agenda, checklistCount),
            const SizedBox(height: 24),
            _sectionTitle('Agenda terdekat', 'Pengingat yang kamu catat.'),
            const SizedBox(height: 11),
            if (agenda.isEmpty)
              _emptyCard(
                icon: Icons.event_available_outlined,
                title: 'Belum ada agenda',
                message:
                    'Atur follow-up atau jadwal interview dari detail lamaran.',
                action: 'Buka agenda',
                onTap: () => _open(context, AgendaPage(store: store)),
              )
            else ...[
              for (final entry in agenda.take(3))
                if (store.applicationJobs[entry.key] case final job?)
                  _agendaCard(context, job, entry.value),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _open(context, AgendaPage(store: store)),
                  icon: const Icon(Icons.arrow_forward, size: 17),
                  label: const Text('Lihat semua agenda'),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _sectionTitle('Jejak terbaru', 'Perubahan status lamaranmu.'),
            const SizedBox(height: 11),
            if (activity.isEmpty)
              _emptyCard(
                icon: Icons.route_outlined,
                title: 'Ceritamu dimulai di sini',
                message:
                    'Catat peluang dan statusnya untuk melihat perjalananmu.',
                action: 'Catat peluang',
                onTap: () => _open(context, ManualApplication(store: store)),
              )
            else
              _activityCard(context, activity.take(4).toList()),
            const SizedBox(height: 24),
            _checklistCard(context, checklistCount),
            const SizedBox(height: 18),
            const Text(
              'Status lamaran dan pengingat dikelola olehmu, lalu disimpan bersama data aplikasi.',
              style: TextStyle(fontSize: 10, height: 1.6, color: muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );

  Widget _overviewCard({
    required int applications,
    required int interviews,
    required int saved,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [plum, Color(0xFF493451)],
      ),
      borderRadius: BorderRadius.circular(23),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: lime, size: 17),
            SizedBox(width: 8),
            Text(
              'PETA PERJALANANMU',
              style: TextStyle(
                color: lime,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Terus bergerak dengan ritmemu sendiri.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _metric('$applications', 'Lamaran'),
            _metric('$interviews', 'Interview'),
            _metric('$saved', 'Tersimpan'),
          ],
        ),
      ],
    ),
  );

  Widget _metric(String value, String label) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            height: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -.5,
        ),
      ),
      const SizedBox(height: 2),
      Text(subtitle, style: const TextStyle(fontSize: 11, color: muted)),
    ],
  );

  Widget _nextStep(
    BuildContext context,
    List<MapEntry<String, DateTime>> agenda,
    int checklistCount,
  ) {
    final overdue = agenda.where(
      (entry) => entry.value.isBefore(DateTime.now()),
    );
    final next = overdue.isNotEmpty
        ? overdue.first
        : (agenda.isEmpty ? null : agenda.first);
    final job = next == null ? null : store.applicationJobs[next.key];
    if (next != null && job != null) {
      final isOverdue = next.value.isBefore(DateTime.now());
      return _actionCard(
        icon: isOverdue
            ? Icons.notifications_active_outlined
            : Icons.event_outlined,
        title: isOverdue
            ? 'Waktunya meninjau follow-up'
            : 'Ada jadwal yang menanti',
        message: '${job.title} · ${formatDateTime(context, next.value)}',
        action: 'Buka lamaran',
        onTap: () => _open(context, JobDetail(job: job, store: store)),
      );
    }
    if (store.applications.isEmpty) {
      return _actionCard(
        icon: Icons.add_task_outlined,
        title: 'Mulai dengan satu peluang',
        message: 'Catat lowongan yang menarik agar progresmu tersusun rapi.',
        action: 'Catat peluang',
        onTap: () => _open(context, ManualApplication(store: store)),
      );
    }
    if (checklistCount < careerChecklist.length) {
      return _actionCard(
        icon: Icons.checklist_rounded,
        title: 'Siapkan bekal berikutnya',
        message:
            '$checklistCount dari ${careerChecklist.length} persiapan karier selesai.',
        action: 'Buka checklist',
        onTap: () => _open(context, CareerGuide(store: store)),
      );
    }
    return _actionCard(
      icon: Icons.self_improvement_outlined,
      title: 'Kamu sudah menyiapkan banyak hal',
      message: 'Lihat agenda atau lanjut jelajahi peluang yang sesuai.',
      action: 'Lihat agenda',
      onTap: () => _open(context, AgendaPage(store: store)),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String message,
    required String action,
    required VoidCallback onTap,
  }) => Card(
    color: lavender.withValues(alpha: .55),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: plum),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: muted, fontSize: 11, height: 1.5),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: Text(action),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
    required String action,
    required VoidCallback onTap,
  }) => Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: lavender,
            foregroundColor: plum,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    color: muted,
                  ),
                ),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text(action),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _agendaCard(BuildContext context, Job job, DateTime at) {
    final isPast = at.isBefore(DateTime.now());
    return Card(
      color: Colors.white,
      child: ListTile(
        onTap: () => _open(context, JobDetail(job: job, store: store)),
        leading: CircleAvatar(
          backgroundColor: isPast ? const Color(0xFFFBE9E8) : lavender,
          foregroundColor: isPast ? const Color(0xFF9E3F46) : plum,
          child: Icon(isPast ? Icons.history : Icons.event_outlined, size: 20),
        ),
        title: Text(
          job.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${job.company}\n${formatDateTime(context, at)}${isPast ? ' · Sudah lewat' : ''}',
          style: TextStyle(
            fontSize: 10,
            height: 1.5,
            color: isPast ? const Color(0xFF9E3F46) : muted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _activityCard(
    BuildContext context,
    List<({String id, StatusChange change})> activity,
  ) => Card(
    color: Colors.white,
    child: Column(
      children: [
        for (var index = 0; index < activity.length; index++)
          if (store.applicationJobs[activity[index].id] case final job?)
            ListTile(
              onTap: () => _open(context, JobDetail(job: job, store: store)),
              leading: CircleAvatar(
                radius: 18,
                backgroundColor: _statusColor(activity[index].change.status),
                child: Icon(
                  _statusIcon(activity[index].change.status),
                  size: 17,
                  color: plum,
                ),
              ),
              title: Text(
                '${activity[index].change.status.label} · ${job.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                '${job.company} · ${MaterialLocalizations.of(context).formatMediumDate(activity[index].change.at)}',
                style: const TextStyle(fontSize: 10, color: muted),
              ),
              trailing: const Icon(Icons.chevron_right, size: 19),
            ),
      ],
    ),
  );

  Widget _checklistCard(BuildContext context, int completed) => Card(
    color: const Color(0xFFEAF3B4).withValues(alpha: .7),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _open(context, CareerGuide(store: store)),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: plum),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Bekal karier',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '$completed/${careerChecklist.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: plum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completed / careerChecklist.length,
              minHeight: 7,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: Colors.white,
              color: plum,
            ),
            const SizedBox(height: 9),
            const Text(
              'Lihat checklist, tips CV, portofolio, dan interview.',
              style: TextStyle(fontSize: 10, color: muted),
            ),
          ],
        ),
      ),
    ),
  );

  Color _statusColor(ApplicationStatus status) => switch (status) {
    ApplicationStatus.planned => lavender,
    ApplicationStatus.applied => const Color(0xFFFFE8C2),
    ApplicationStatus.interview => const Color(0xFFDCD1F0),
    ApplicationStatus.accepted => const Color(0xFFEAF3B4),
    ApplicationStatus.rejected => const Color(0xFFF8DCDD),
  };

  IconData _statusIcon(ApplicationStatus status) => switch (status) {
    ApplicationStatus.planned => Icons.bookmark_outline,
    ApplicationStatus.applied => Icons.send_outlined,
    ApplicationStatus.interview => Icons.forum_outlined,
    ApplicationStatus.accepted => Icons.celebration_outlined,
    ApplicationStatus.rejected => Icons.replay_outlined,
  };

  void _open(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
}
