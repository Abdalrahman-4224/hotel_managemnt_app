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
  Future<void> clearAll() async {
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'auth_user');
  }
}
