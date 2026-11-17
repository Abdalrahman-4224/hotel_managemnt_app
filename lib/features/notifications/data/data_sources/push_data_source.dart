import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

/// Tells the server which phone belongs to the signed-in user, so Firebase
/// can deliver to it.
class PushDataSource {
  final ApiClient apiClient;

  PushDataSource(this.apiClient);

  /// [platform] is `android` or `ios`. Safe to repeat: the server moves the
  /// token to whoever is signed in now and refreshes its "last seen".
  Future<void> register(String token, String platform) async {
    await apiClient.post(
      '/push/register',
      data: {'token': token, 'platform': platform},
    );
  }

  /// Call before the JWT is cleared on sign-out, while it still works.
  Future<void> unregister(String token) async {
    await apiClient.post('/push/unregister', data: {'token': token});
  }
}

final pushDataSourceProvider = Provider<PushDataSource>((ref) {
  return PushDataSource(ref.watch(apiClientProvider));
});
