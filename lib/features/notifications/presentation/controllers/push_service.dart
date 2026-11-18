import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_router.dart';
import '../../data/data_sources/push_data_source.dart';
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
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _open(response.payload ?? ''),
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Open app: Android shows nothing of its own, so the app draws it.
    FirebaseMessaging.onMessage.listen(_showWhileOpen);

    // Tapped while the app sat in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (m) => _open(m.data['go'] ?? ''),
    );

    // Tapped while the app was closed: this is why it started.
    final first = await FirebaseMessaging.instance.getInitialMessage();
    if (first != null) _open(first.data['go'] ?? '');

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
      payload: data['go'] ?? '',
    );
  }

  /// A tap: show what it is about, and let the bell catch up.
  void _open(String go) {
    _bumpInbox();
    final route = routeForGo(go);
    if (route != null) ref.read(appRouterProvider).go(route);
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
