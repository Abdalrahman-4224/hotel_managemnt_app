import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Saves the login token and the logged-in user on the device.
class TokenStorage {
  final storage = const FlutterSecureStorage();

  Future<String?> read() {
    return storage.read(key: 'auth_token');
  }

  Future<void> save(String token) {
    return storage.write(key: 'auth_token', value: token);
  }

  Future<void> clear() {
    return storage.delete(key: 'auth_token');
  }

  /// The user is saved as a JSON string.
  Future<String?> readUser() {
    return storage.read(key: 'auth_user');
  }

  Future<void> saveUser(String userJson) {
    return storage.write(key: 'auth_user', value: userJson);
  }

  /// Removes the token and the user (used on sign out).
  /// The fingerprint token is kept: signing in with it again is its purpose.
  Future<void> clearAll() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'auth_user');
  }

  /// This phone's fingerprint sign-in token, issued by the server when the
  /// user turned fingerprint sign-in on. It is not the password: the server
  /// can revoke it, and it expires. Read only after a successful scan.
  Future<String?> readDeviceToken() => storage.read(key: 'device_token');

  Future<void> saveDeviceToken(String token) {
    return storage.write(key: 'device_token', value: token);
  }

  Future<void> clearDeviceToken() => storage.delete(key: 'device_token');
}
