import 'dart:io';

class AppConstants {
  const AppConstants._();

  static const appName = 'Hotel Management';

  // Android emulator: 10.0.2.2 = your computer's localhost.
  // iOS simulator: shares the Mac's network, so localhost works.
  // Real phone: use your computer's IP, e.g. http://192.168.1.5:3000/api
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);
}
