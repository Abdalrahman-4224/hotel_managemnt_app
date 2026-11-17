import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../data_sources/notifications_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource dataSource;

  NotificationsRepositoryImpl(this.dataSource);

  @override
  Future<NotificationPage> list({
    int limit = 50,
    String? before,
    bool unreadOnly = false,
  }) async {
    final envelope = await dataSource.fetchList(
      limit: limit,
      before: before,
      unreadOnly: unreadOnly,
    );
    return NotificationModel.pageFromEnvelope(envelope);
  }

  @override
  Future<int> unreadCount() async {
    final data = await dataSource.fetchUnreadCount();
    return parseInt(data['count']) ?? 0;
  }

  @override
  Future<int> markRead({List<String>? ids, bool all = false}) async {
    final data = await dataSource.markRead(
      all ? {'all': true} : {'ids': ids ?? const <String>[]},
    );
    return parseInt(data['unread_count']) ?? 0;
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepositoryImpl(
    ref.watch(notificationsDataSourceProvider),
  );
});
