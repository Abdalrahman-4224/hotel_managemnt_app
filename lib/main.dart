import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/notifications/presentation/controllers/push_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push is an extra: if Firebase can't start (an old phone with no Play
  // services, a bad config), the app still has to run.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.current);
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  } catch (error) {
    debugPrint('[push] Firebase did not start: $error');
  }

  runApp(const ProviderScope(child: App()));
}
