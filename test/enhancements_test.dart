import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langkah_kerja/models/application_insights.dart';
import 'package:langkah_kerja/models/job.dart';
import 'package:langkah_kerja/models/user_data.dart';
import 'package:langkah_kerja/screens/compare.dart';
import 'package:langkah_kerja/screens/detail.dart';
import 'package:langkah_kerja/screens/help.dart';
import 'package:langkah_kerja/screens/insights.dart';
import 'package:langkah_kerja/services/job_store.dart';

Job realJob(String id) => Job(
  id: id,
  title: 'Posisi $id',
  company: 'Tim $id',
  location: 'Jakarta',
  description: 'Flutter dan Figma',
  url: 'https://example.com/jobs/$id',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 10, 23, 12);

  test(
    'ringkasan menghitung status saat ini, menyisihkan demo dan agenda selesai',
    () {
      final stats = ApplicationInsights(
        applications: {
          'a': ApplicationStatus.interview,
          'b': ApplicationStatus.accepted,
          'demo-design': ApplicationStatus.planned,
        },
        jobs: {
          'a': realJob('a'),
          'b': realJob('b'),
          'demo-design': demoJobs.first,
        },
        timeline: {},
        followUps: {
          'a': now.subtract(const Duration(hours: 1)),
          'b': now.subtract(const Duration(days: 1)),
        },
        now: now,
      );
      expect(stats.total, 2);
      expect(stats.active, 1);
      expect(stats.overdue, 1);
      expect(stats.counts[ApplicationStatus.accepted], 1);
    },
  );

  test(
    'rentang memakai waktu pertama dicatat; data tanpa riwayat hanya semua waktu',
    () {
      final stats = ApplicationInsights(
        applications: {
          'old': ApplicationStatus.interview,
          'new': ApplicationStatus.applied,
          'unknown': ApplicationStatus.planned,
          'edge': ApplicationStatus.planned,
        },
        jobs: {
          for (final id in ['old', 'new', 'unknown', 'edge']) id: realJob(id),
        },
        timeline: {
          'old': [
            StatusChange(ApplicationStatus.interview, now),
            StatusChange(
              ApplicationStatus.planned,
              now.subtract(const Duration(days: 30)),
            ),
          ],
          'new': [StatusChange(ApplicationStatus.applied, now)],
          'edge': [
            StatusChange(ApplicationStatus.planned, DateTime(2026, 10, 17)),
          ],
        },
        followUps: {'new': now.add(const Duration(days: 1))},
        now: now,
        days: 7,
      );
      expect(stats.total, 2);
      expect(stats.activity.length, 2);
      expect(stats.upcoming, 1);
    },
  );

  test('kata kunci hanya berasal dari minat dan teks yang tersedia', () {
    expect(matchingKeywords(realJob('a'), 'Flutter, SQL; Figma\nflutter'), [
      'Flutter',
      'Figma',
      'flutter',
    ]);
    expect(matchingKeywords(realJob('a'), ''), isEmpty);
  });

  Future<JobStore> store() async {
    SharedPreferences.setMockInitialValues({});
    return JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true;
  }

  Future<void> host(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(MaterialApp(home: child));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'perbandingan membatasi tiga pilihan dan menampilkan data yang tidak tersedia',
    (tester) async {
      final data = await store();
      for (final job in demoJobs) {
        await data.toggleSave(job);
      }
      await host(tester, ComparePage(store: data));
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(CheckboxListTile).at(i));
        await tester.pumpAndSettle();
      }
      final fourth = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile).at(3),
      );
      expect(fourth.onChanged, isNull);
      await tester.scrollUntilVisible(find.text('Ringkasan perbandingan'), 200);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('compare-demo-design')),
        200,
      );
      expect(find.text('Tidak disebutkan'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('bantuan dapat dicari dan dibaca tanpa backend', (tester) async {
    await host(tester, const HelpPage());
    await tester.enterText(find.byType(TextField), 'rekening');
    await tester.pumpAndSettle();
    expect(
      find.text('Bagaimana mengenali lowongan mencurigakan?'),
      findsOneWidget,
    );
    expect(find.text('Mengapa lowongan belum muncul?'), findsNothing);
    await tester.tap(find.text('Bagaimana mengenali lowongan mencurigakan?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('HTTPS hanya melindungi koneksi'),
      findsOneWidget,
    );
  });

  testWidgets('tautan luar dapat dibatalkan sebelum memanggil browser', (
    tester,
  ) async {
    bool? opened;
    await host(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              opened = await openJobLink(context, 'https://example.com/jobs/1');
            },
            child: const Text('Buka'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    expect(find.text('example.com'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(opened, isFalse);
  });

  testWidgets(
    'catatan kotor bertahan saat kembali dibatalkan lalu bisa diabaikan',
    (tester) async {
      final data = await store();
      final job = realJob('a');
      await data.track(job, ApplicationStatus.applied, note: 'Tersimpan');
      await host(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => JobDetail(job: job, store: data),
                ),
              ),
              child: const Text('Detail'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Detail'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'Draf belum disimpan');
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Catatan belum disimpan'), findsOneWidget);
      await tester.tap(find.text('Lanjut menulis'));
      await tester.pumpAndSettle();
      expect(find.text('Draf belum disimpan'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abaikan perubahan'));
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsOneWidget);
      expect(data.notes[job.id], 'Tersimpan');
    },
  );

  testWidgets('halaman baru nyaman pada 320px dengan teks 2x', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = await store();
    for (final job in demoJobs) {
      await data.toggleSave(job);
    }
    for (final page in [
      InsightsPage(store: data),
      ComparePage(store: data),
      const HelpPage(),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: page,
        ),
      );
      await tester.pumpAndSettle();
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 9; i++) {
        await tester.drag(scrollable, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
