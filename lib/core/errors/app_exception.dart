import 'dart:async';

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
String errorText(Object? error) {
  // Requests sent together with `.wait` fail as one ParallelWaitError that
  // wraps each request's own error. Show the server's message, not a generic one.
  if (error is ParallelWaitError) {
    final inner = _firstAppException(error.errors);
    if (inner != null) return inner.message;
  }
  return error is AppException ? error.message : 'حدث خطأ ما، حاول مرة أخرى';
}

/// `.wait` on a record reports its errors as a record of AsyncError?, on a
/// list as a list. Records can't be walked, so the record case reads the
/// fields the app's own `.wait` calls produce (two or three requests).
AppException? _firstAppException(Object? errors) {
  final candidates = switch (errors) {
    final List<Object?> list => list,
    (final a, final b) => [a, b],
    (final a, final b, final c) => [a, b, c],
    _ => const <Object?>[],
  };
  for (final e in candidates) {
    final inner = e is AsyncError ? e.error : e;
    if (inner is AppException) return inner;
  }
  return null;
}
