import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/controllers/permissions_controller.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    // Token expired: log out, and the router sends the user to login.
    onUnauthorized: () {
      ref.read(authControllerProvider.notifier).sessionExpired();
    },
    // Action refused: the role's permissions may have been changed, so load
    // them again and let the UI hide whatever is gone.
    onForbidden: () => ref.read(permissionsEpochProvider.notifier).bump(),
  );
});
