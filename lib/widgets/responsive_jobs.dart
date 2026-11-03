import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/job_store.dart';
import 'job_card.dart';

class ResponsiveJobs extends StatelessWidget {
  const ResponsiveJobs({
    super.key,
    required this.jobs,
    required this.store,
    this.compact = false,
  });
  final List<Job> jobs;
  final JobStore store;
  final bool compact;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.35);
      final columns = constraints.maxWidth >= 700 * scale ? 2 : 1;
      final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 4,
        children: [
          for (final job in jobs)
            SizedBox(
              key: ValueKey('job-cell-${job.id}'),
              width: width,
              child: JobCard(job: job, store: store, compact: compact),
            ),
        ],
      );
    },
  );
}
