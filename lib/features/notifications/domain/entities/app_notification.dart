/// One row of the bell inbox: the same notification the server also pushes to
/// the phone. The wording is written by the server, ready to show.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.go,
    required this.urgent,
    required this.createdAt,
    required this.isRead,
  });

  /// Sent as a string; it is what `POST /notifications/read` takes.
  final String id;

  final String title;
  final String body;

  /// A Lucide icon name from the server, e.g. `wrench`, `door-open`.
  final String icon;

  /// The screen this is about, as a path of the web app: `/tasks`,
  /// `/bookings`, `/bookings/new`. Anything else means the home screen.
  final String go;

  final bool urgent;
  final DateTime createdAt;
  final bool isRead;

  AppNotification asRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    icon: icon,
    go: go,
    urgent: urgent,
    createdAt: createdAt,
    isRead: true,
  );
}

/// A page of the inbox, with the badge count for the whole inbox (not just
/// this page).
class NotificationPage {
  const NotificationPage({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}
