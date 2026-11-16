import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/core/api/api_client.dart';
import 'package:hotel_managemnt_app/core/errors/app_exception.dart';
import 'package:hotel_managemnt_app/core/storage/token_storage.dart';

class _MemoryTokenStorage extends TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}

/// Answers 401 to every request, but only once [release] completes - like a
/// slow reply to a request that was sent before the user signed in.
class _Slow401Adapter implements HttpClientAdapter {
  final release = Completer<void>();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await release.future;
    return ResponseBody.fromString(
      jsonEncode({'success': false, 'message': 'Invalid or expired token'}),
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MemoryTokenStorage storage;
  late _Slow401Adapter adapter;
  late ApiClient client;
  late int expired;

  setUp(() {
    storage = _MemoryTokenStorage();
    adapter = _Slow401Adapter();
    expired = 0;
    client = ApiClient(tokenStorage: storage, onUnauthorized: () => expired++);
    client.dio.httpClientAdapter = adapter;
  });

  // The fingerprint bug: closing the system prompt resumes the app, which
  // reloads the permissions while still signed out. That request's 401 came
  // back just after the fingerprint sign-in had saved its token, and wiped it.
  test(
    'a 401 for a request sent before sign-in keeps the new session',
    () async {
      final stale = client.get('/auth/permissions'); // sent with no token
      await pumpEventQueue();
      await storage.save('fresh-token'); // sign-in finishes meanwhile
      adapter.release.complete();

      await expectLater(stale, throwsA(isA<AppException>()));
      expect(storage.token, 'fresh-token');
      expect(expired, 0);
    },
  );

  test(
    'a 401 for a request sent with an older token keeps the new one',
    () async {
      await storage.save('old-token');
      final stale = client.get('/rooms');
      await pumpEventQueue();
      await storage.save('fresh-token');
      adapter.release.complete();

      await expectLater(stale, throwsA(isA<AppException>()));
      expect(storage.token, 'fresh-token');
      expect(expired, 0);
    },
  );

  test('a 401 for the current token still ends the session', () async {
    await storage.save('current-token');
    final request = client.get('/rooms');
    await pumpEventQueue();
    adapter.release.complete();

    await expectLater(request, throwsA(isA<AppException>()));
    expect(storage.token, isNull);
    expect(expired, 1);
  });
}
