import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:langkah_kerja/main.dart';
import 'package:langkah_kerja/services/job_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/fonts/Manrope.ttf'));
    await font.load();
  });
  const cases = <({Size size, double scale, bool rail})>[
    (size: Size(320, 800), scale: 1, rail: false),
    (size: Size(390, 844), scale: 1, rail: false),
    (size: Size(844, 390), scale: 1, rail: false),
    (size: Size(1024, 768), scale: 1, rail: true),
    (size: Size(1440, 900), scale: 1, rail: true),
    (size: Size(320, 800), scale: 2, rail: false),
    (size: Size(1024, 768), scale: 2, rail: true),
  ];
  for (final scenario in cases) {
    testWidgets(
      'employee ${scenario.size.width}x${scenario.size.height} teks ${scenario.scale}x',
      (tester) async {
        tester.view.physicalSize = scenario.size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});
        final store = JobStore(await SharedPreferences.getInstance())
          ..onboardingComplete = true
          ..useDemo();
        tester.platformDispatcher.textScaleFactorTestValue = scenario.scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(LangkahKerjaApp(store: store));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('employee-rail')),
          scenario.rail ? findsOneWidget : findsNothing,
        );
        for (final label in ['Beranda', 'Eksplorasi', 'Lamaran']) {
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();
          final scrollable = find
              .byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              )
              .last;
          for (var n = 0; n < 4; n++) {
            await tester.drag(scrollable, const Offset(0, -320));
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isNull,
              reason: '$label ${scenario.size}',
            );
          }
        }
        await tester.pumpWidget(const SizedBox());
        store.dispose();
      },
    );
  }

  testWidgets('query dan favorit bertahan setelah layar berubah ukuran', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final store = JobStore(await SharedPreferences.getInstance())
      ..onboardingComplete = true
      ..useDemo();
    await store.toggleSave(store.jobs.first);
    await tester.pumpWidget(LangkahKerjaApp(store: store));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('home-search')),
      'Flutter',
    );
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('home-search')))
          .controller!
          .text,
      'Flutter',
    );
    expect(store.saved.length, 1);
    expect(find.byKey(const ValueKey('employee-rail')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    store.dispose();
  });
}
