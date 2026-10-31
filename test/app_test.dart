import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langkah_kerja/main.dart';
import 'package:langkah_kerja/services/job_store.dart';
import 'package:langkah_kerja/models/job.dart';
import 'package:langkah_kerja/models/reminder_target.dart';
import 'package:langkah_kerja/services/reminders.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
    await font.load();
  });
  testWidgets('menu pilih peran menggantikan onboarding dan memilih cari kerja', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = JobStore(prefs);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('Cari Kerja (Employee)'), findsOneWidget);
    expect(find.text('Post Kerja (Employer)'), findsOneWidget);
    expect(find.text('Mulai Cari Kerja'), findsOneWidget);
    await tester.tap(find.text('Mulai Cari Kerja'));
    await tester.pumpAndSettle();
    expect(store.onboardingComplete, isTrue);
    expect(store.activeRole, 'employee');
    expect((JobStore(prefs)..restore()).onboardingComplete, isTrue);
    expect(find.text('Eksplorasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('menu pilih peran dapat memilih post kerja employer', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = JobStore(prefs);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    expect(find.text('Post Kerja (Employer)'), findsOneWidget);
    expect(find.text('Mulai Pasang Lowongan'), findsOneWidget);
    await tester.tap(find.text('Mulai Pasang Lowongan'));
    await tester.pumpAndSettle();
    expect(store.onboardingComplete, isTrue);
    expect(store.activeRole, 'employer');
    expect(find.text('Lowongan'), findsWidgets);
    expect(find.text('Pasang Lowongan Baru'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('lamaran manual tersimpan tanpa membutuhkan akun atau feed', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lamaran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catat lowongan sendiri'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('manual-title')),
      'Flutter Engineer',
    );
    await tester.enterText(
      find.byKey(const ValueKey('manual-company')),
      'Perusahaan Contoh',
    );
    await tester.scrollUntilVisible(
      find.text('Simpan catatan lamaran'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Simpan catatan lamaran'));
    await tester.pumpAndSettle();
    expect(store.applications.length, 1);
    expect(store.applicationJobs.values.single.title, 'Flutter Engineer');
    expect(store.applicationJobs.values.single.demo, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('menu hamburger membuka perjalanan tanpa tab profil ganda', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    await store.track(demoJobs.first, ApplicationStatus.interview);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();

    // Profile and tools live in the drawer; primary tabs remain unchanged.
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Eksplorasi'), findsOneWidget);
    expect(find.text('Lamaran'), findsOneWidget);
    expect(find.text('Profil & preferensi'), findsNothing);
    await tester.tap(find.byTooltip('Buka menu utama'));
    await tester.pumpAndSettle();
    expect(find.text('Peluang'), findsOneWidget);
    expect(find.text('Buat CV'), findsOneWidget);
    expect(find.text('Surat lamaran kerja'), findsOneWidget);
    await tester.tap(find.text('Peluang'));
    await tester.pumpAndSettle();
    expect(find.text('Temukan\npeluangmu.'), findsOneWidget);

    await tester.tap(find.byTooltip('Buka menu utama'));
    await tester.pumpAndSettle();
    final drawerScroll = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Upload identitas'),
      100,
      scrollable: drawerScroll,
    );
    expect(find.text('Pasfoto 3×4'), findsOneWidget);
    expect(find.text('Upload identitas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Profil & preferensi'),
      100,
      scrollable: drawerScroll,
    );
    expect(find.text('Profil & preferensi'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Perjalanan karier'),
      100,
      scrollable: drawerScroll,
    );
    await tester.tap(find.text('Perjalanan karier'));
    await tester.pumpAndSettle();

    expect(find.text('Perjalanan karier'), findsOneWidget);
    expect(find.text('PETA PERJALANANMU'), findsOneWidget);
    expect(find.text('Interview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('draf surat mengambil posisi dari peluang yang sudah dimuat', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Buka menu utama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Surat lamaran kerja'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Junior UI/UX Designer · Studio Tumbuh'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'Junior UI/UX Designer',
    );
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).controller!.text,
      'Studio Tumbuh',
    );

    await tester.scrollUntilVisible(
      find.text('Susun draf surat'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(Scaffold).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text('Susun draf surat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Susun draf surat'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('DRAF UNTUK DITINJAU'),
      150,
      scrollable: find
          .descendant(
            of: find.byType(Scaffold).last,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('DRAF UNTUK DITINJAU'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('ketukan pengingat membuka lamaran dan menolak agenda lama', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    final job = demoJobs.first;
    final at = DateTime.now().add(const Duration(days: 1));
    await store.track(job, ApplicationStatus.interview);
    await store.setFollowUp(job.id, at);
    final pending = ReminderService.instance.pendingOpen;
    addTearDown(() => pending.value = null);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    pending.value = ReminderTarget(job.id, at.millisecondsSinceEpoch);
    await tester.pumpAndSettle();
    expect(find.text('Detail lowongan'), findsOneWidget);
    expect(find.text(job.title), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await store.setFollowUp(job.id, at.add(const Duration(hours: 1)));
    pending.value = ReminderTarget(job.id, at.millisecondsSinceEpoch);
    await tester.pumpAndSettle();
    expect(find.text('Detail lowongan'), findsNothing);
    expect(find.text('Agenda ini sudah diubah atau dihapus.'), findsOneWidget);
    expect(pending.value, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('kategori dan filter remote tetap bekerja pada layar kecil', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eksplorasi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Desain'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Junior UI/UX Designer'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Junior UI/UX Designer'), findsOneWidget);
    expect(find.text('Flutter Developer Intern'), findsNothing);
    await tester.tap(find.text('Teknologi'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Filter lowongan'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Kerja remote'),
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Kerja remote'));
    await tester.tap(find.text('Tampilkan lowongan'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Belum ada yang cocok'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Belum ada yang cocok'), findsOneWidget);
    await tester.tap(find.byTooltip('Buka menu utama'));
    await tester.pumpAndSettle();
    final drawerScroll = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Profil & preferensi'),
      100,
      scrollable: drawerScroll,
    );
    await tester.tap(find.text('Profil & preferensi'));
    await tester.pumpAndSettle();
    expect(find.text('Nama panggilan'), findsOneWidget);
    await tester.tap(find.text('Lamaran'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Langkahmu dimulai di sini'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Langkahmu dimulai di sini'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('teks besar tetap dapat digunakan pada layar 320 piksel', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 740);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final store = JobStore(await SharedPreferences.getInstance())..useDemo();
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai melangkah'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    for (final label in ['Eksplorasi', 'Lamaran']) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: label);
    }
    await tester.tap(find.byTooltip('Buka menu utama'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Profil & preferensi'),
      100,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(find.text('Profil & preferensi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil & preferensi'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'alur demo: buka lowongan, simpan favorit, lalu catat interview',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = JobStore(await SharedPreferences.getInstance())
        ..onboardingComplete = true
        ..useDemo();
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(LangkahKerjaApp(store: store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eksplorasi'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Junior UI/UX Designer'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Junior UI/UX Designer'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Simpan favorit'));
      await tester.pumpAndSettle();
      expect(store.saved.length, 1);
      await tester.scrollUntilVisible(
        find.text('Status lamaran'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byType(DropdownButtonFormField<ApplicationStatus>).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interview').last);
      await tester.pumpAndSettle();
      expect(store.applications.values.single.label, 'Interview');
      expect(tester.takeException(), isNull);
    },
  );
}
