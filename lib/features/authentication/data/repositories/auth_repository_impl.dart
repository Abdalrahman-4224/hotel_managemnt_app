import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/biometric_kind.dart';
import '../../domain/entities/permissions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../data_sources/biometric_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;
  final BiometricDataSource biometric;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage, this.biometric);

  @override
  Future<AuthUser> signIn(String username, String password) async {
    return _saveSession(await remoteDataSource.signIn(username, password));
  }

  /// Saves a `{ token, user }` session from either sign-in, so the user stays
  /// logged in after closing the app.
  Future<AuthUser> _saveSession(Map<String, dynamic> data) async {
    final user = UserModel.fromJson(data['user']);
    await tokenStorage.save(data['token'] as String);
    await tokenStorage.saveUser(jsonEncode(user.toJson()));
    return user.toEntity();
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on AppException {
      // Even if the server call fails (e.g. no internet),
      // we still log out on this device.
    }
    await tokenStorage.clearAll();
  }

  @override
  Future<AuthUser?> getSavedUser() async {
    final token = await tokenStorage.read();
    final userJson = await tokenStorage.readUser();
    if (token == null || userJson == null) return null;

    final user = UserModel.fromJson(jsonDecode(userJson));
    return user.toEntity();
  }

  @override
  Future<void> clearSession() async {
    await tokenStorage.clearAll();
  }

  @override
  Future<Permissions> getPermissions() async {
    final data = await remoteDataSource.fetchPermissions();
    return Permissions(
      isSuperadmin: data['is_superadmin'] == true,
      codes: Set<String>.from(data['permissions'] ?? const []),
    );
  }

  @override
  Future<AuthUser> updateProfile(
    AuthUser current, {
    required String fullName,
    String? email,
  }) async {
    final data = await remoteDataSource.updateMe({
      'full_name': fullName,
      // The server can't clear a field, so an empty email is just not sent.
      if (email != null && email.isNotEmpty) 'email': email,
    });
    final updated = current.copyWith(
      fullName: data['full_name'],
      email: data['email'],
    );
    await tokenStorage.saveUser(
      jsonEncode(UserModel.fromEntity(updated).toJson()),
    );
    return updated;
  }

  @override
  Future<void> changePassword(String current, String next) async {
    await remoteDataSource.changePassword(current, next);
    // The server revoked every phone's fingerprint token. This phone just
    // proved the new password, so it quietly enrolls again.
    if (await tokenStorage.readDeviceToken() == null) return;
    try {
      await _enroll(next);
    } on AppException {
      await tokenStorage.clearDeviceToken();
    }
  }

  @override
  Future<BiometricKind?> biometricKind() => biometric.availableKind();

  /// The wording for a prompt or a message. The fallback is only reached if
  /// the phone lost its sensor since the screen was drawn, and then it only
  /// picks the words for the failure that follows.
  Future<BiometricKind> _kind() async =>
      await biometric.availableKind() ?? BiometricKind.fingerprint;

  @override
  Future<bool> biometricEnabled() async {
    return await tokenStorage.readDeviceToken() != null;
  }

  @override
  Future<bool> enableBiometric(String password) async {
    final kind = await _kind();
    // Scan first, so a cancelled scan never leaves a token on the server.
    final scanned = await biometric.authenticate(kind.enableReason, kind);
    if (!scanned) return false;
    await _enroll(password);
    return true;
  }

  /// The server checks the password and issues this phone's device token.
  Future<void> _enroll(String password) async {
    final data = await remoteDataSource.enrollDevice(
      password,
      defaultTargetPlatform.name,
    );
    await tokenStorage.saveDeviceToken(data['device_token'] as String);
  }

  @override
  Future<void> disableBiometric() async {
    final token = await tokenStorage.readDeviceToken();
    if (token != null) {
      try {
        await remoteDataSource.revokeDevice(token);
      } on AppException {
        // Offline: the token is still forgotten here, and expires on its own.
      }
    }
    await tokenStorage.clearDeviceToken();
  }

  @override
  Future<AuthUser?> signInWithBiometric() async {
    final kind = await _kind();
    final token = await tokenStorage.readDeviceToken();
    if (token == null) throw AppException(kind.notSetUp);
    final scanned = await biometric.authenticate(kind.signInReason, kind);
    if (!scanned) return null;
    try {
      return await _saveSession(await remoteDataSource.deviceSignIn(token));
    } on AppException catch (error) {
      if (error.statusCode != 401) rethrow;
      // Revoked or expired (e.g. the password changed on another phone).
      await tokenStorage.clearDeviceToken();
      throw AppException(kind.expired, statusCode: 401);
    }
  }

  @override
  Future<void> requestActivation(String username, String phone) {
    return remoteDataSource.requestActivation(username, phone);
  }

  @override
  Future<String> verifyActivation(String username, String phone, String code) {
    return remoteDataSource.verifyActivation(username, phone, code);
  }

  @override
  Future<void> completeActivation(String activationToken, String password) {
    return remoteDataSource.completeActivation(activationToken, password);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepositoryImpl(
    remoteDataSource,
    tokenStorage,
    ref.watch(biometricDataSourceProvider),
  );
});
