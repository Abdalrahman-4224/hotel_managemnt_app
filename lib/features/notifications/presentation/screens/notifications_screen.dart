import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/app_notification.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_row.dart';

/// Everything the hotel has sent this user: new tasks, finished work, a room
/// that came free, a departure that is due.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Fetches the next page a little before the list runs out.
  void _onScroll() {
    if (_scroll.position.extentAfter < 400) {
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  /// Opens what the notification is about, and marks it read on the way.
  void _open(AppNotification notification) {
    ref.read(notificationsControllerProvider.notifier).markRead(notification);
    final route = routeForGo(notification.go);
    if (route != null) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(notificationsControllerProvider);
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    final items = async.value ?? const <AppNotification>[];

    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            showBack: Navigator.of(context).canPop(),
            subtitle: unread == 0 ? 'كل شيء مقروء' : '$unread غير مقروء',
            title: 'الإشعارات',
            actions: [
              if (unread > 0)
                NzOutlineButton(
                  label: 'تعليم الكل',
                  icon: LucideIcons.checkCheck,
                  height: 44.r,
                  radius: AppRadius.r14,
                  fontSize: 14,
                  onPressed: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .markAllRead(),
                ),
            ],
          ),
          Expanded(
            child: NzAsyncBody(
              hasValue: async.hasValue,
              error: async.error,
              onRetry: () =>
                  ref.read(notificationsControllerProvider.notifier).refresh(),
              child: () => RefreshIndicator(
                onRefresh: () => ref
                    .read(notificationsControllerProvider.notifier)
                    .refresh(),
                child: items.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 120.r),
                          const NzStateMessage(
                            text: 'لا توجد إشعارات بعد.\nسنخبرك هنا بالمهام والمغادرات والغرف التي تتحرّر.',
                          ),
                        ],
                      )
                    : _list(items),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<AppNotification> items) {
    final loadingMore = ref
        .read(notificationsControllerProvider.notifier)
        .hasMore;
    return ListView.separated(
      controller: _scroll,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s14,
        AppSpacing.s16,
        NzBottomNav.bodyPadding(context),
      ),
      itemCount: items.length + (loadingMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.s8),
      itemBuilder: (context, i) {
        if (i == items.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return NotificationRow(
          notification: items[i],
          onTap: () => _open(items[i]),
        );
      },
    );
  }
}

/// The app route a notification's `go` path points at, or null for the paths
/// that have no screen of their own (the home screen is already behind it).
String? routeForGo(String go) => switch (go) {
  '/tasks' => AppRoutes.tasks,
  '/bookings' => AppRoutes.bookings,
  '/bookings/new' => AppRoutes.addBooking,
  // Electricity lives on the room map, exactly as it does on the website:
  // there is no separate power screen to send these to.
  '/power' || '/rooms' => AppRoutes.rooms,
  _ => null,
};
