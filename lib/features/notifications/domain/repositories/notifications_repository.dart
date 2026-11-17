import '../entities/app_notification.dart';

/// The bell inbox. Any signed-in hotel user may read their own.
/// The real implementation is in data/repositories/notifications_repository_impl.dart.
abstract class NotificationsRepository {
  /// Newest first. [before] takes the page older than that notification.
  Future<NotificationPage> list({int limit, String? before, bool unreadOnly});

  /// Just the badge number, without the list.
  Future<int> unreadCount();

  /// Marks [ids] read, or the whole inbox with [all]. Returns what is left unread.
  Future<int> markRead({List<String>? ids, bool all = false});
}
