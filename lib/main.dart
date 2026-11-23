import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';
import 'features/notifications/presentation/controllers/push_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The fonts ship inside the app (assets/fonts), so the first start works
  // offline and the phone never asks Google's servers for them.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(_fontLicenses);

  // Every screen is laid out for a phone held upright.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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

/// The three bundled font families are under the SIL Open Font License,
/// which asks for its text to travel with the fonts.
Stream<LicenseEntry> _fontLicenses() async* {
  for (final family in const ['IBMPlexSansArabic', 'NotoNaskhArabic', 'Lora']) {
    final text = await rootBundle.loadString('assets/fonts/$family-OFL.txt');
    yield LicenseEntryWithLineBreaks([family], text);
  }
}
