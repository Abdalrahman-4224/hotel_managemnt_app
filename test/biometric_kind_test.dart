import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:hotel_managemnt_app/features/authentication/data/data_sources/biometric_data_source.dart';
import 'package:hotel_managemnt_app/features/authentication/domain/entities/biometric_kind.dart';
import 'package:hotel_managemnt_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:hotel_managemnt_app/features/authentication/presentation/controllers/biometric_controller.dart';
import 'package:hotel_managemnt_app/features/authentication/presentation/screens/login_screen.dart';

/// Keeps the login screen off the network and off secure storage.
class _FakeAuth extends AuthController {
  @override
  AuthState build() => const AuthState(status: AuthStatus.loggedOut);
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  required BiometricKind? kind,
  bool enabled = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(_FakeAuth.new),
        biometricStatusProvider.overrideWith(
          (ref) async => (kind: kind, enabled: enabled),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, _) => const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: LoginScreen(),
        ),
      ),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('which sensor the phone reported', () {
    test('iOS names Face ID', () {
      expect(kindFromTypes([BiometricType.face]), BiometricKind.face);
    });

    test('iOS names Touch ID', () {
      expect(
        kindFromTypes([BiometricType.fingerprint]),
        BiometricKind.fingerprint,
      );
    });

    // Android never names the sensor, only how strong it is.
    test('Android reads as a fingerprint', () {
      expect(kindFromTypes([BiometricType.strong]), BiometricKind.fingerprint);
      expect(kindFromTypes([BiometricType.weak]), BiometricKind.fingerprint);
    });

    test('a phone offering both leads with the face', () {
      expect(
        kindFromTypes([BiometricType.fingerprint, BiometricType.face]),
        BiometricKind.face,
      );
    });
  });

  group('wording', () {
    test('face never says fingerprint', () {
      const face = BiometricKind.face;
      for (final text in [
        face.signInTitle,
        face.enableReason,
        face.signInReason,
        face.enableHint,
        face.promptHint,
        face.notEnrolled,
        face.failed,
        face.enabledToast,
        face.disabledToast,
        face.notSetUp,
        face.expired,
      ]) {
        expect(text, isNot(contains('بصم')), reason: text);
        expect(text, isNot(contains('إصبع')), reason: text);
      }
    });

    test('messages are built from the feature name', () {
      expect(BiometricKind.face.enabledToast, 'تم تفعيل الدخول بالوجه');
      expect(
        BiometricKind.fingerprint.disabledToast,
        'تم إيقاف الدخول بالبصمة',
      );
      expect(BiometricKind.face.notSetUp, contains('الدخول بالوجه'));
      expect(BiometricKind.fingerprint.expired, contains('الدخول بالبصمة'));
    });

    test('each kind has its own icon', () {
      expect(BiometricKind.face.icon, LucideIcons.scanFace);
      expect(BiometricKind.fingerprint.icon, LucideIcons.fingerprint);
    });
  });

  group('login screen', () {
    testWidgets('an iPhone with Face ID offers the face', (tester) async {
      await _pumpLogin(tester, kind: BiometricKind.face);

      expect(find.text('الدخول بالوجه'), findsOneWidget);
      expect(find.text('الدخول بالبصمة'), findsNothing);
      expect(find.byIcon(LucideIcons.scanFace), findsOneWidget);
    });

    testWidgets('a phone with a reader offers the fingerprint', (tester) async {
      await _pumpLogin(tester, kind: BiometricKind.fingerprint);

      expect(find.text('الدخول بالبصمة'), findsOneWidget);
      expect(find.byIcon(LucideIcons.fingerprint), findsOneWidget);
    });

    testWidgets('turned off: no button at all', (tester) async {
      await _pumpLogin(tester, kind: BiometricKind.face, enabled: false);

      expect(find.text('الدخول بالوجه'), findsNothing);
    });

    testWidgets('no sensor: no button at all', (tester) async {
      await _pumpLogin(tester, kind: null);

      expect(find.text('الدخول بالبصمة'), findsNothing);
      expect(find.text('الدخول بالوجه'), findsNothing);
    });
  });
}
