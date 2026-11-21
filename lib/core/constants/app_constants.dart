class AppConstants {
  const AppConstants._();

  static const appName = 'فندقي بلس';

  /// The shared team server. The backend and the database both live there, so
  /// nothing needs to run on your machine to use the app.
  static const teamServer = 'https://api.funduqiplus.com/api';

  /// Where the app sends its requests.
  ///
  /// To point it at a backend running on your own machine instead:
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
  ///
  /// 10.0.2.2 is the Android emulator's address for your computer's localhost.
  /// On the iOS simulator use http://localhost:3000/api; on a real phone use
  /// your computer's IP, e.g. http://192.168.1.5:3000/api.
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: teamServer,
  );

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  /// The assistant answers one question at a time for the whole server, so a
  /// reply can wait in line well past [receiveTimeout].
  static const assistantTimeout = Duration(seconds: 90);
}
