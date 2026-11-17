import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/app_notification.dart';

class NotificationModel {
  const NotificationModel._();

  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      // Sent as a string, but a number would still parse.
      id: json['notification_id'].toString(),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      go: json['go']?.toString() ?? '/',
      // Real booleans on this endpoint; the push payload uses "1"/"0".
      urgent: json['urgent'] == true || json['urgent'] == '1',
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      isRead: json['is_read'] == true,
    );
  }

  static NotificationPage pageFromEnvelope(Map<String, dynamic> envelope) {
    final rows = envelope['data'];
    return NotificationPage(
      items: [
        if (rows is List)
          for (final row in rows) fromJson(Map<String, dynamic>.from(row)),
      ],
      unreadCount: parseInt(envelope['unread_count']) ?? 0,
    );
  }
}
