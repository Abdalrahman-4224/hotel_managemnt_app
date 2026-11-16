import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/biometric_kind.dart';

/// What this phone recognises its owner by ([kind], null if it can't), and
/// whether signing in that way is turned on.
/// Invalidate it after turning it on or off.
final biometricStatusProvider =
    FutureProvider<({BiometricKind? kind, bool enabled})>((ref) async {
      final repository = ref.read(authRepositoryProvider);
      return (
        kind: await repository.biometricKind(),
        enabled: await repository.biometricEnabled(),
      );
    });

extension BiometricKindIcon on BiometricKind {
  IconData get icon => switch (this) {
    BiometricKind.fingerprint => LucideIcons.fingerprint,
    BiometricKind.face => LucideIcons.scanFace,
  };
}
