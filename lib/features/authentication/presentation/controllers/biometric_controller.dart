import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';

/// Whether this phone can use fingerprint sign-in, and whether it's turned on.
/// Invalidate it after turning fingerprint sign-in on or off.
final biometricStatusProvider =
    FutureProvider<({bool available, bool enabled})>((ref) async {
      final repository = ref.read(authRepositoryProvider);
      return (
        available: await repository.biometricAvailable(),
        enabled: await repository.biometricEnabled(),
      );
    });
