class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;

  /// HTTP status code, or null when the server was never reached.
  final int? statusCode;

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => message;
}

/// Text to show for any error caught in the UI.
String errorText(Object? error) =>
    error is AppException ? error.message : 'حدث خطأ ما، حاول مرة أخرى';
