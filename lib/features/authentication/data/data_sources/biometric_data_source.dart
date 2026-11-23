import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/biometric_kind.dart';

/// Which sensor the phone reported.
///
/// iOS names it: `face` for Face ID, `fingerprint` for Touch ID. Android only
/// reports how strong the biometric is, never which one, so there the label
/// follows the reader that virtually every Android phone has.
BiometricKind kindFromTypes(List<BiometricType> types) =>
    types.contains(BiometricType.face)
    ? BiometricKind.face
    : BiometricKind.fingerprint;

/// The phone's fingerprint or face sensor.
class BiometricDataSource {
  final _auth = LocalAuthentication();

  /// What this phone recognises its owner by, or null if it can't: no sensor,
  /// or nothing enrolled on it.
  Future<BiometricKind?> availableKind() async {
    try {
      if (!await _auth.isDeviceSupported()) return null;
      final types = await _auth.getAvailableBiometrics();
      return types.isEmpty ? null : kindFromTypes(types);
    } catch (_) {
      return null;
    }
  }

  /// Shows the system prompt. True if the scan matched, false if the user
  /// cancelled. Throws an [AppException] for anything they should be told.
  Future<bool> authenticate(String reason, BiometricKind kind) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: kind.signInTitle,
            signInHint: kind.promptHint,
            cancelButton: 'إلغاء',
          ),
          // Without these the iOS prompt keeps the plugin's English defaults
          // in an app that is Arabic everywhere else. iOS takes no title or
          // hint: the sheet shows NSFaceIDUsageDescription and the reason.
          // The fallback button is empty on purpose - it offers the device
          // passcode, which biometricOnly above refuses anyway.
          const IOSAuthMessages(
            cancelButton: 'إلغاء',
            localizedFallbackTitle: '',
          ),
        ],
      );
    } on LocalAuthException catch (error) {
      switch (error.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.timeout:
          return false;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
          throw AppException(kind.notEnrolled);
        default:
          throw AppException(kind.failed);
      }
    }
  }
}

final biometricDataSourceProvider = Provider<BiometricDataSource>((ref) {
  return BiometricDataSource();
});
