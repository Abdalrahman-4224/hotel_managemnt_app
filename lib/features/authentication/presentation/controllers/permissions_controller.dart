import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/permissions.dart';
import 'auth_controller.dart';

/// Bumped to force a reload of the permissions. It's a plain counter so that
/// nothing the ApiClient depends on has to depend on the permissions provider,
/// which would be a circular dependency.
class PermissionsEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final permissionsEpochProvider = NotifierProvider<PermissionsEpoch, int>(
  PermissionsEpoch.new,
);

/// The signed-in user's permission codes, from GET /auth/permissions.
/// Reloads after a new login, and whenever the epoch is bumped.
final permissionsProvider = FutureProvider<Permissions>((ref) {
  // Watching the user id means a new login loads the new user's permissions.
  ref.watch(authControllerProvider.select((state) => state.user?.id));
  ref.watch(permissionsEpochProvider);
  return ref.read(authRepositoryProvider).getPermissions();
});

/// What the UI reads to show or hide an action:
///
///   if (ref.watch(canProvider).can(Permissions.taskCreate)) ...
///
/// While the codes are loading, nothing is allowed, so a button never flashes
/// into view and then disappears.
final canProvider = Provider<Permissions>((ref) {
  return ref.watch(permissionsProvider).value ?? const Permissions.none();
});
