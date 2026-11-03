import 'job.dart';
import 'user_data.dart';

/// Descriptive counts of the user's records, never a hiring prediction.
class ApplicationInsights {
  ApplicationInsights({
    required Map<String, ApplicationStatus> applications,
    required Map<String, Job> jobs,
    required Map<String, List<StatusChange>> timeline,
    required Map<String, DateTime> followUps,
    required DateTime now,
    int days = 0,
    bool includeDemo = false,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    final start = days == 0 ? null : today.subtract(Duration(days: days - 1));
    for (final entry in applications.entries) {
      final job = jobs[entry.key];
      if (job == null || (!includeDemo && job.demo)) continue;
      final events =
          (timeline[entry.key] ?? []).where((e) => !e.at.isAfter(now)).toList()
            ..sort((a, b) => a.at.compareTo(b.at));
      // Old backups may have no history. Do not invent a first-recorded date.
      if (start != null &&
          (events.isEmpty || events.first.at.isBefore(start))) {
        continue;
      }
      counts.update(entry.value, (n) => n + 1);
      total++;
      for (final event in events) {
        if (start == null || !event.at.isBefore(start)) {
          activity.add((job: job, change: event));
        }
      }
      final closed =
          entry.value == ApplicationStatus.accepted ||
          entry.value == ApplicationStatus.rejected;
      final due = followUps[entry.key];
      if (!closed && due != null) {
        if (due.isBefore(now)) overdue++;
        if (!due.isBefore(now) &&
            due.isBefore(today.add(const Duration(days: 7)))) {
          upcoming++;
        }
      }
    }
    activity.sort((a, b) => b.change.at.compareTo(a.change.at));
  }

  final counts = {for (final status in ApplicationStatus.values) status: 0};
  final activity = <({Job job, StatusChange change})>[];
  int total = 0, overdue = 0, upcoming = 0;
  int get active =>
      counts[ApplicationStatus.planned]! +
      counts[ApplicationStatus.applied]! +
      counts[ApplicationStatus.interview]!;
}

List<String> matchingKeywords(Job job, String skills) {
  final words = skills
      .split(RegExp(r'[,;\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();
  return words
      .where((word) => job.searchableText.contains(word.toLowerCase()))
      .take(8)
      .toList();
}
