import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_managemnt_app/core/widgets/design_frame.dart';
import 'package:hotel_managemnt_app/core/widgets/nz_sheet.dart';
import 'package:hotel_managemnt_app/features/assistant/domain/entities/assistant_reply.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/controllers/assistant_controller.dart';
import 'package:hotel_managemnt_app/features/assistant/presentation/screens/assistant_screen.dart';

/// The iPad runs the phone layout inside DesignFrame, upright and on its
/// side. These are the real iPad screens in points.
const _ipads = <String, Size>{
  'iPad mini portrait': Size(744, 1133),
  'iPad mini landscape': Size(1133, 744),
  'iPad 13" portrait': Size(1032, 1376),
  'iPad 13" landscape': Size(1376, 1032),
};

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final entry in _ipads.entries) {
    testWidgets('${entry.key}: phone proportions, centred, no overflow', (
      tester,
    ) async {
      await _pump(tester, entry.value);

      final box = tester.getSize(find.byType(AssistantScreen));
      final expectedWidth =
          entry.value.height * designSize.width / designSize.height;
      expect(box.width, closeTo(expectedWidth, 0.5));
      expect(box.height, entry.value.height);
      // Centred: equal bands either side.
      final left = tester.getTopLeft(find.byType(AssistantScreen)).dx;
      expect(left, closeTo((entry.value.width - expectedWidth) / 2, 0.5));
      // One scale for both axes, so `.w`, `.h` and `.r` agree.
      expect(ScreenUtil().scaleWidth, closeTo(ScreenUtil().scaleHeight, 1e-9));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('turning the iPad re-measures the frame', (tester) async {
    await _pump(tester, const Size(1032, 1376));
    final upright = tester.getSize(find.byType(AssistantScreen)).width;

    _setSize(tester, const Size(1376, 1032));
    await tester.pump();
    final onSide = tester.getSize(find.byType(AssistantScreen)).width;

    expect(onSide, closeTo(1032 * 390 / 844, 0.5));
    expect(onSide, lessThan(upright));
    expect(ScreenUtil().scaleWidth, closeTo(1032 / 844, 1e-9));
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape with the keyboard up: no overflow', (tester) async {
    await _pump(tester, const Size(1133, 744));
    // The iPad mini keyboard on its side covers about 400 of 744 points.
    tester.view.viewInsets = const FakeViewPadding(bottom: 400 * 3);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('tall form sheet stays above the keyboard on its side', (
    tester,
  ) async {
    await _pump(tester, const Size(1133, 744));
    final context = tester.element(find.byType(AssistantScreen));
    showNzTallSheet<void>(
      context,
      header: (_) => const Text('مهمة جديدة'),
      body: (_) => Column(
        children: [
          for (var i = 0; i < 6; i++) const TextField(),
          const TextField(key: Key('last')),
        ],
      ),
      footer: (_) =>
          const SizedBox(key: Key('save'), height: 48, width: double.infinity),
    );
    await tester.pumpAndSettle();

    tester.view.viewInsets = const FakeViewPadding(bottom: 400 * 3);
    await tester.tap(find.byKey(const Key('last')));
    await tester.pumpAndSettle();

    const keyboardTop = 744 - 400;
    expect(
      tester.getBottomLeft(find.byKey(const Key('save'))).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(
      tester.getBottomLeft(find.byKey(const Key('last'))).dy,
      lessThanOrEqualTo(keyboardTop),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a phone passes straight through', (tester) async {
    await _pump(tester, const Size(390, 844));
    expect(tester.getSize(find.byType(AssistantScreen)), const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
}

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
}

Future<void> _pump(WidgetTester tester, Size size) async {
  _setSize(tester, size);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assistantStatusProvider.overrideWith(
          (ref) async =>
              const AssistantStatus(enabled: true, ready: true, waiting: 0),
        ),
      ],
      child: ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        builder: (_, _) => MaterialApp(
          builder: (context, screen) => DesignFrame(child: screen!),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: const AssistantScreen(),
        ),
      ),
    ),
  );
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
