import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_managemnt_app/core/api/api_client.dart';
import 'package:hotel_managemnt_app/core/api/api_providers.dart';
import 'package:hotel_managemnt_app/core/routes/app_routes.dart';
import 'package:hotel_managemnt_app/core/storage/token_storage.dart';
import 'package:hotel_managemnt_app/features/authentication/domain/entities/auth_user.dart';
import 'package:hotel_managemnt_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:hotel_managemnt_app/features/notifications/data/data_sources/push_data_source.dart';
import 'package:hotel_managemnt_app/features/notifications/data/models/notification_model.dart';
import 'package:hotel_managemnt_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:hotel_managemnt_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:hotel_managemnt_app/features/notifications/presentation/widgets/notification_row.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _FakeTokenStorage extends TokenStorage {
  @override
  Future<String?> read() async => 'test-token';
}

class _SignedIn extends AuthController {
  @override
  AuthState build() => const AuthState(
    status: AuthStatus.loggedIn,
    user: AuthUser(
      id: 7,
      hotelId: 3,
      roleId: 5,
      departmentId: 2,
      username: 'reception1',
      fullName: 'علي حسن',
      roleName: 'receptionist',
      phone: '+9647701234567',
      email: null,
    ),
  );
}

class _SignedOut extends AuthController {
  @override
  AuthState build() => const AuthState(status: AuthStatus.loggedOut);
}

/// Answers each request from a map of path -> body, and records what was sent.
class _FakeApi implements HttpClientAdapter {
  _FakeApi(this.responses);

  final Map<String, Map<String, dynamic>> responses;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = responses[options.path];
    return ResponseBody.fromString(
      jsonEncode(
        body ?? {'success': false, 'message': 'no stub for ${options.path}'},
      ),
      body == null ? 404 : 200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _row(
  int id, {
  bool read = false,
  bool urgent = false,
  String go = '/tasks',
  String icon = 'wrench',
}) => {
  'notification_id': '$id',
  'title': 'مهمة جديدة $id',
  'body': 'من سارة · غرفة 204',
  'icon': icon,
  'go': go,
  'urgent': urgent,
  'created_at': DateTime.now()
      .subtract(const Duration(minutes: 5))
      .toUtc()
      .toIso8601String(),
  'is_read': read,
};

ApiClient _client(_FakeApi api) {
  final client = ApiClient(tokenStorage: _FakeTokenStorage());
  client.dio.httpClientAdapter = api;
  return client;
}

ProviderContainer _container(_FakeApi api) {
  final container = ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(_client(api)),
      authControllerProvider.overrideWith(_SignedIn.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpInbox(WidgetTester tester, _FakeApi api) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(_client(api)),
        authControllerProvider.overrideWith(_SignedIn.new),
      ],
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        builder: (_, _) => const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: NotificationsScreen(),
        ),
      ),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('parsing', () {
    test('reads a page and the badge beside it', () {
      final page = NotificationModel.pageFromEnvelope({
        'success': true,
        'data': [_row(4812, urgent: true), _row(4811, read: true)],
        'unread_count': 3,
      });

      expect(page.unreadCount, 3);
      expect(page.items, hasLength(2));
      expect(page.items.first.id, '4812');
      expect(page.items.first.urgent, isTrue);
      expect(page.items.first.isRead, isFalse);
      expect(page.items.last.isRead, isTrue);
    });

    test('an id sent as a number still reads as its string', () {
      final n = NotificationModel.fromJson({
        ..._row(12),
        'notification_id': 12,
      });
      expect(n.id, '12');
    });

    test('a missing body or icon does not break the row', () {
      final n = NotificationModel.fromJson({
        'notification_id': '1',
        'title': 'عنوان',
        'created_at': '2026-11-16T09:00:00.000Z',
      });
      expect(n.body, '');
      expect(n.go, '/');
      expect(n.urgent, isFalse);
      expect(iconFor(n.icon), LucideIcons.bell);
    });

    test('every icon the server sends has a real one', () {
      for (final name in [
        'alarm-clock',
        'check-check',
        'clipboard-check',
        'clipboard-list',
        'clock',
        'door-open',
        'hand-platter',
        'sparkles',
        'wrench',
        'x',
      ]) {
        expect(iconFor(name), isNot(LucideIcons.bell), reason: name);
      }
    });
  });

  group('where a notification opens', () {
    test('the three known screens', () {
      expect(routeForGo('/tasks'), AppRoutes.tasks);
      expect(routeForGo('/bookings'), AppRoutes.bookings);
      expect(routeForGo('/bookings/new'), AppRoutes.addBooking);
    });

    test('anything else stays where it is', () {
      expect(routeForGo('/'), isNull);
      expect(routeForGo('/rooms/7'), isNull);
      expect(routeForGo(''), isNull);
    });
  });

  test('relative time', () {
    final now = DateTime(2026, 11, 16, 12);
    String ago(Duration d) => timeAgo(now.subtract(d), now: now);

    expect(ago(const Duration(seconds: 20)), 'الآن');
    expect(ago(const Duration(minutes: 5)), 'منذ 5 دقيقة');
    expect(ago(const Duration(hours: 3)), 'منذ 3 ساعة');
    expect(ago(const Duration(days: 1)), 'أمس');
    expect(ago(const Duration(days: 3)), 'منذ 3 أيام');
    expect(ago(const Duration(days: 30)), '17/10/2026');
  });

  group('the inbox talks to the server', () {
    test('loads the newest page and publishes the badge', () async {
      final api = _FakeApi({
        '/notifications': {
          'success': true,
          'data': [_row(2), _row(1, read: true)],
          'unread_count': 1,
        },
      });
      final container = _container(api);

      final items = await container.read(
        notificationsControllerProvider.future,
      );
      expect(items, hasLength(2));
      expect(container.read(unreadCountProvider).value, 1);

      final sent = api.requests.single;
      expect(sent.path, '/notifications');
      expect(sent.queryParameters['limit'], 50);
      // No cursor on the first page.
      expect(sent.queryParameters.containsKey('before'), isFalse);
      expect(sent.headers['Authorization'], 'Bearer test-token');
    });

    test('marking one read updates the row and the badge', () async {
      final api = _FakeApi({
        '/notifications': {
          'success': true,
          'data': [_row(2), _row(1)],
          'unread_count': 2,
        },
        '/notifications/read': {
          'success': true,
          'data': {'unread_count': 1},
        },
      });
      final container = _container(api);
      final items = await container.read(
        notificationsControllerProvider.future,
      );

      await container
          .read(notificationsControllerProvider.notifier)
          .markRead(items.first);

      final after = container.read(notificationsControllerProvider).value!;
      expect(after.first.isRead, isTrue);
      expect(after.last.isRead, isFalse);
      expect(container.read(unreadCountProvider).value, 1);
      expect(api.requests.last.data, {
        'ids': ['2'],
      });
    });

    test('marking all read sends one request for the lot', () async {
      final api = _FakeApi({
        '/notifications': {
          'success': true,
          'data': [_row(2), _row(1)],
          'unread_count': 2,
        },
        '/notifications/read': {
          'success': true,
          'data': {'unread_count': 0},
        },
      });
      final container = _container(api);
      await container.read(notificationsControllerProvider.future);

      await container
          .read(notificationsControllerProvider.notifier)
          .markAllRead();

      final after = container.read(notificationsControllerProvider).value!;
      expect(after.every((n) => n.isRead), isTrue);
      expect(container.read(unreadCountProvider).value, 0);
      expect(api.requests.last.data, {'all': true});
    });

    test('a row already read is not sent again', () async {
      final api = _FakeApi({
        '/notifications': {
          'success': true,
          'data': [_row(1, read: true)],
          'unread_count': 0,
        },
      });
      final container = _container(api);
      final items = await container.read(
        notificationsControllerProvider.future,
      );

      await container
          .read(notificationsControllerProvider.notifier)
          .markRead(items.single);

      expect(api.requests, hasLength(1)); // the list only
    });

    test('signed out, the badge asks the server nothing', () async {
      final api = _FakeApi({});
      final container = ProviderContainer(
        overrides: [
          apiClientProvider.overrideWithValue(_client(api)),
          authControllerProvider.overrideWith(_SignedOut.new),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(unreadCountProvider.future), 0);
      expect(api.requests, isEmpty);
    });
  });

  group('registering this phone for push', () {
    test('register sends the token and the platform', () async {
      final api = _FakeApi({
        '/push/register': {'success': true, 'message': 'Device registered'},
      });
      final container = _container(api);

      await container
          .read(pushDataSourceProvider)
          .register('fcm-token-123', 'android');

      final sent = api.requests.single;
      expect(sent.path, '/push/register');
      expect(sent.data, {'token': 'fcm-token-123', 'platform': 'android'});
      expect(sent.headers['Authorization'], 'Bearer test-token');
    });

    test('unregister names the token being withdrawn', () async {
      final api = _FakeApi({
        '/push/unregister': {'success': true, 'message': 'Device unregistered'},
      });
      final container = _container(api);

      await container.read(pushDataSourceProvider).unregister('fcm-token-123');

      expect(api.requests.single.data, {'token': 'fcm-token-123'});
    });
  });

  testWidgets('the inbox shows its rows, unread first-class', (tester) async {
    await _pumpInbox(
      tester,
      _FakeApi({
        '/notifications': {
          'success': true,
          'data': [_row(3, urgent: true), _row(2, read: true)],
          'unread_count': 1,
        },
      }),
    );

    expect(find.text('مهمة جديدة 3'), findsOneWidget);
    expect(find.text('مهمة جديدة 2'), findsOneWidget);
    expect(find.text('عاجل'), findsOneWidget);
    expect(find.text('1 غير مقروء'), findsOneWidget);
    expect(find.text('تعليم الكل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty inbox says so and offers nothing to mark', (
    tester,
  ) async {
    await _pumpInbox(
      tester,
      _FakeApi({
        '/notifications': {'success': true, 'data': [], 'unread_count': 0},
      }),
    );

    expect(find.textContaining('لا توجد إشعارات بعد'), findsOneWidget);
    expect(find.text('تعليم الكل'), findsNothing);
    expect(find.text('كل شيء مقروء'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
