import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class NotificationsDataSource {
  final ApiClient apiClient;

  NotificationsDataSource(this.apiClient);

  /// The envelope: `data` is the page, `unread_count` the badge number.
  Future<Map<String, dynamic>> fetchList({
    required int limit,
    String? before,
    bool unreadOnly = false,
  }) {
    return apiClient.getEnvelope(
      '/notifications',
      query: {'limit': limit, 'before': ?before, if (unreadOnly) 'unread': 1},
    );
  }

  Future<Map<String, dynamic>> fetchUnreadCount() async {
    final data = await apiClient.get('/notifications/unread-count');
    return Map<String, dynamic>.from(data);
  }

  /// `{ ids: [...] }` or `{ all: true }`. Returns `{ unread_count }`.
  Future<Map<String, dynamic>> markRead(Map<String, dynamic> body) async {
    final data = await apiClient.post('/notifications/read', data: body);
    return Map<String, dynamic>.from(data);
  }
}

final notificationsDataSourceProvider = Provider<NotificationsDataSource>((
  ref,
) {
  return NotificationsDataSource(ref.watch(apiClientProvider));
});
