import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../../../core/errors/app_exception.dart';

/// The phone's fingerprint (or face) sensor.
class BiometricDataSource {
  final _auth = LocalAuthentication();

  /// True if the phone has a sensor and at least one fingerprint enrolled.
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Shows the system prompt. True if the scan matched, false if the user
  /// cancelled. Throws an [AppException] for anything they should be told.
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'الدخول بالبصمة',
            signInHint: 'المس مستشعر البصمة',
            cancelButton: 'إلغاء',
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
          throw const AppException('لا توجد بصمة مسجّلة على هذا الجهاز');
        default:
          throw const AppException('تعذّر التحقق بالبصمة، حاول مرة أخرى');
      }
    }
  }
}

final biometricDataSourceProvider = Provider<BiometricDataSource>((ref) {
  return BiometricDataSource();
});
