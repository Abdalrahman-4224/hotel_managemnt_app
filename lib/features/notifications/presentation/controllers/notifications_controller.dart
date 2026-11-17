import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification.dart';

/// How many rows one page of the inbox holds.
const _pageSize = 50;

/// Bumped whenever something should re-read the badge: a new login, the app
/// coming back to the foreground, or notifications just marked read.
class NotificationsEpoch extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final notificationsEpochProvider = NotifierProvider<NotificationsEpoch, int>(
  NotificationsEpoch.new,
);

/// The number on the bell. It reloads for a new user and whenever the epoch
/// is bumped, and the inbox can hand it a fresh count directly.
class UnreadCount extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final userId = ref.watch(
      authControllerProvider.select((state) => state.user?.id),
    );
    ref.watch(notificationsEpochProvider);
    // Signed out: nothing to count, and the request would only be a 401.
    if (userId == null) return 0;
    return ref.read(notificationsRepositoryProvider).unreadCount();
  }

  /// What the inbox just learned, so the bell doesn't ask again.
  void set(int count) => state = AsyncValue.data(count);
}

final unreadCountProvider = AsyncNotifierProvider<UnreadCount, int>(
  UnreadCount.new,
);

/// The inbox screen's list. Loads the newest page, then older ones on demand.
class NotificationsController extends AsyncNotifier<List<AppNotification>> {
  /// False once the server returns a short page: there is nothing older.
  var _hasMore = true;
  var _loadingMore = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<AppNotification>> build() async {
    final page = await ref
        .read(notificationsRepositoryProvider)
        .list(limit: _pageSize);
    _hasMore = page.items.length == _pageSize;
    _publishCount(page.unreadCount);
    return page.items;
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .list(limit: _pageSize);
      _hasMore = page.items.length == _pageSize;
      _publishCount(page.unreadCount);
      return page.items;
    });
  }

  /// Appends the page older than the last row we hold.
  Future<void> loadMore() async {
    final current = state.value;
    if (_loadingMore || !_hasMore || current == null || current.isEmpty) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(notificationsRepositoryProvider)
          .list(limit: _pageSize, before: current.last.id);
      _hasMore = page.items.length == _pageSize;
      state = AsyncValue.data([...current, ...page.items]);
    } catch (_) {
      // An older page that fails is not worth an error screen: the rows
      // already on screen stay, and the user can pull to try again.
      _hasMore = false;
    } finally {
      _loadingMore = false;
    }
  }

  /// Marks one row read, showing it immediately.
  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    _apply((n) => n.id == notification.id ? n.asRead() : n);
    final left = await ref
        .read(notificationsRepositoryProvider)
        .markRead(ids: [notification.id]);
    _publishCount(left);
  }

  Future<void> markAllRead() async {
    _apply((n) => n.asRead());
    final left = await ref
        .read(notificationsRepositoryProvider)
        .markRead(all: true);
    _publishCount(left);
  }

  void _apply(AppNotification Function(AppNotification) change) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([for (final n in current) change(n)]);
  }

  /// Keeps the bell in step with what the list just learned, without a
  /// second request.
  void _publishCount(int count) {
    ref.read(unreadCountProvider.notifier).set(count);
  }
}

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<AppNotification>>(
      NotificationsController.new,
    );
