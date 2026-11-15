import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  /// Returns `{ token, user }` from the server.
  Future<Map<String, dynamic>> signIn(String username, String password) async {
    final data = await apiClient.post(
      '/auth/signin',
      data: {'username': username, 'password': password},
    );
    return data;
  }

  /// Revokes the current token on the server.
  Future<void> signOut() async {
    await apiClient.post('/auth/signout');
  }

  /// Edits the signed-in user's own name and email. Returns the updated user.
  /// The phone can't be changed here - the server refuses it.
  Future<Map<String, dynamic>> updateMe(Map<String, dynamic> fields) async {
    final data = await apiClient.put('/auth/me', data: fields);
    return data;
  }

  Future<void> changePassword(String current, String next) async {
    await apiClient.put(
      '/auth/me/password',
      data: {'current_password': current, 'new_password': next},
    );
  }

  /// Turns fingerprint sign-in on for this phone. The server checks the
  /// password once and returns `{ device_token, expires_at }`.
  Future<Map<String, dynamic>> enrollDevice(
    String password,
    String deviceName,
  ) async {
    final data = await apiClient.post(
      '/auth/biometric/enroll',
      data: {'password': password, 'device_name': deviceName},
    );
    return data;
  }

  /// Trades the device token for a session: `{ token, user }`.
  Future<Map<String, dynamic>> deviceSignIn(String deviceToken) async {
    final data = await apiClient.post(
      '/auth/biometric/signin',
      data: {'device_token': deviceToken},
    );
    return data;
  }

  /// Revokes this phone's token on the server.
  Future<void> revokeDevice(String deviceToken) async {
    await apiClient.delete(
      '/auth/biometric',
      data: {'device_token': deviceToken},
    );
  }

  /// Returns `{ is_superadmin, permissions: [codes] }`.
  Future<Map<String, dynamic>> fetchPermissions() async {
    final data = await apiClient.get('/auth/permissions');
    return data;
  }

  /// Activation step 1: sends a code by SMS (if the details match an invite).
  Future<void> requestActivation(String username, String phone) async {
    await apiClient.post(
      '/auth/activate/request',
      data: {'username': username, 'phone': phone},
    );
  }

  /// Activation step 2: returns the short-lived activation_token.
  Future<String> verifyActivation(
    String username,
    String phone,
    String code,
  ) async {
    final data = await apiClient.post(
      '/auth/activate/verify',
      data: {'username': username, 'phone': phone, 'code': code},
    );
    return data['activation_token'];
  }

  /// Activation step 3: sets the password.
  Future<void> completeActivation(
    String activationToken,
    String password,
  ) async {
    await apiClient.post(
      '/auth/activate/complete',
      data: {'activation_token': activationToken, 'password': password},
    );
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});
