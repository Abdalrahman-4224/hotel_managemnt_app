import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/data_sources/push_data_source.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../screens/notifications_screen.dart';
import 'notifications_controller.dart';

/// Must match `default_notification_channel_id` in AndroidManifest.xml: the
/// server sends no channel, so Android falls back to that name, and the
/// notifications the app draws itself have to land in the same place.
const _channelId = 'funduqi_alerts';

/// High importance is what makes Android slide the notification down as a
/// banner instead of dropping it silently into the drawer.
const _channel = AndroidNotificationChannel(
  _channelId,
  'تنبيهات الفندق',
  description: 'المهام والمغادرات والغرف التي تتحرّر',
  importance: Importance.high,
);

/// Runs in its own isolate when a message arrives and the app is not running.
/// The system draws the notification from the message's own title and body,
/// so there is nothing to do here - but Firebase wants a handler registered.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {}

/// Push notifications: registers this phone with the server, shows messages
/// that arrive while the app is open, and opens the right screen on a tap.
class PushService {
  PushService(this.ref);

  final Ref ref;
  final _local = FlutterLocalNotificationsPlugin();

  /// The token last given to the server, so sign-out can withdraw exactly it.
  String? _registeredToken;
  var _listening = false;

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  /// After a sign-in, and on every app start while signed in. Asks for
  /// permission the first time, then hands the token to the server.
  Future<void> start() async {
    if (!_supported) return;
    try {
      await _listen();
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      if (!await _apnsReady()) return;

      // getToken is deprecated in favour of register()/onRegistered, but those
      // give the Firebase Installation ID, and the server sends with
      // sendEachForMulticast, which only accepts registration tokens.
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _register(token);
    } catch (error) {
      // Push is an extra: a phone without Play services, or a server that
      // refuses the token, must not stop the app from working.
      debugPrint('[push] start failed: $error');
    }
  }

  /// iOS hands out no Firebase token until Apple has answered the
  /// registration that requestPermission starts, and getToken throws until
  /// then. Apple usually answers within a second; a simulator never does, and
  /// neither does a phone that is offline. Giving up here is not a failure:
  /// start() runs again on every app start while signed in.
  Future<bool> _apnsReady() async {
    if (!Platform.isIOS) return true;
    for (var waited = Duration.zero;
        waited < const Duration(seconds: 5);
        waited += const Duration(milliseconds: 400)) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    debugPrint('[push] no APNs token yet; will try again next start');
    return false;
  }

  /// Before the token is cleared on sign-out, while it still authenticates.
  Future<void> stop() async {
    final token = _registeredToken;
    _registeredToken = null;
    if (token == null) return;
    try {
      await ref.read(pushDataSourceProvider).unregister(token);
    } on AppException catch (error) {
      // Offline, or the session already gone: the server drops tokens that
      // Firebase rejects anyway.
      debugPrint('[push] unregister failed: ${error.message}');
    }
    try {
      // Throw the token away on the phone too. Without this, a failed call
      // above would leave the device still subscribed, and the next person
      // to sign in here would inherit the old registration.
      await FirebaseMessaging.instance.unregister();
    } catch (error) {
      debugPrint('[push] could not drop the token: $error');
    }
  }

  Future<void> _register(String token) async {
    await ref.read(pushDataSourceProvider).register(token, _platform);
    _registeredToken = token;
  }

  /// Wires the three ways a message reaches the app. Done once per run.
  Future<void> _listen() async {
    if (_listening) return;
    _listening = true;

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Firebase asks for the permission in start(); these default to
        // true, which would put a second ask first and leave the status
        // start() reads the result of a prompt it never showed. This plugin
        // only has to draw notifications, so it asks for nothing.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _openPayload(response.payload ?? ''),
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Open app: Android shows nothing of its own, so the app draws it.
    FirebaseMessaging.onMessage.listen(_showWhileOpen);

    // Tapped while the app sat in the background.
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _openMessage(m.data));

    // Tapped while the app was closed: this is why it started.
    final first = await FirebaseMessaging.instance.getInitialMessage();
    if (first != null) _openMessage(first.data);

    // Firebase replaces the token now and then. Same reason as above for the
    // deprecated stream: onRegistered carries a different identifier.
    // ignore: deprecated_member_use
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await _register(token);
      } catch (error) {
        debugPrint('[push] token refresh failed: $error');
      }
    });
  }

  void _showWhileOpen(RemoteMessage message) {
    _bumpInbox();
    final data = message.data;
    final title = message.notification?.title ?? data['title'];
    final body = message.notification?.body ?? data['body'];
    if (title == null && body == null) return;

    _local.show(
      // The server's own id, so the same notification never doubles up.
      id: int.tryParse(data['id']?.toString() ?? '') ?? message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: data['urgent'] == '1' ? Priority.max : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // The id travels with the tap, so it can be marked read: a local
      // notification hands back only this string.
      payload: '${data['id'] ?? ''}|${data['go'] ?? ''}',
    );
  }

  /// A tap on a notification the app drew itself: `id|go`.
  void _openPayload(String payload) {
    final cut = payload.indexOf('|');
    if (cut < 0) return _open(go: payload);
    return _open(
      id: payload.substring(0, cut),
      go: payload.substring(cut + 1),
    );
  }

  /// A tap on a notification the system drew, from the message's own data.
  void _openMessage(Map<String, dynamic> data) =>
      _open(id: data['id']?.toString(), go: data['go']?.toString());

  /// A tap: mark it read, then show what it is about. Navigation does not
  /// wait for the server - the screen opens now, the badge catches up.
  void _open({String? id, String? go}) {
    if (id == null || id.isEmpty) {
      _bumpInbox();
    } else {
      _markRead(id);
    }
    final route = routeForGo(go ?? '');
    if (route != null) ref.read(appRouterProvider).go(route);
  }

  /// Opening a notification is reading it, so the count has to come down.
  /// Reading it inside the inbox screen already did this; a tap on the push
  /// itself did not, which left the bell counting notifications the user had
  /// just read.
  Future<void> _markRead(String id) async {
    try {
      final left = await ref
          .read(notificationsRepositoryProvider)
          .markRead(ids: [id]);
      // The server's own number, so the bell never drifts.
      ref.read(unreadCountProvider.notifier).set(left);
      // Any open inbox still shows the row unread.
      ref.invalidate(notificationsControllerProvider);
    } catch (error) {
      debugPrint('[push] could not mark $id read: $error');
      // Offline: at least re-read the badge and the list.
      _bumpInbox();
    }
  }

  /// The badge and any open inbox are now out of date.
  void _bumpInbox() {
    ref.read(notificationsEpochProvider.notifier).bump();
    ref.invalidate(notificationsControllerProvider);
  }

  /// Firebase is only set up for the phones.
  bool get _supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));
