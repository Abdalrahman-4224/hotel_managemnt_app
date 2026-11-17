// Firebase for the funduqi-plus project, the same one the server sends from.
//
// Written from android/app/google-services.json and ios/Runner/GoogleService-Info.plist
// (what `flutterfire configure` generates). These values are not secrets: they
// ship inside every copy of the app. Replace this file only by regenerating it
// from new config files.
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  /// The options for the phone this code is running on.
  static FirebaseOptions get current {
    if (kIsWeb) {
      throw UnsupportedError('Firebase is set up for Android and iOS only.');
    }
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    throw UnsupportedError('Firebase is set up for Android and iOS only.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8I_Dr_0vjIV0iRWpI_JWb_W9x9kB5lkc',
    appId: '1:830754969789:android:4c3a0a2999f09364877fd4',
    messagingSenderId: '830754969789',
    projectId: 'funduqi-plus',
    storageBucket: 'funduqi-plus.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgndDTrVa9SHaYNqTVW2u8TksmfkfnTuc',
    appId: '1:830754969789:ios:0ed3d9cf00b01fcc877fd4',
    messagingSenderId: '830754969789',
    projectId: 'funduqi-plus',
    storageBucket: 'funduqi-plus.firebasestorage.app',
    iosBundleId: 'com.funduqiplus.app',
  );
}
