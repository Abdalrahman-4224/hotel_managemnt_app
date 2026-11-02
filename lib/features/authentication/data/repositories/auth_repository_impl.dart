import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/permissions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<AuthUser> signIn(String username, String password) async {
    final data = await remoteDataSource.signIn(username, password);

    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    // Save both, so the user stays logged in after closing the app.
    await tokenStorage.save(token);
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
  return AuthRepositoryImpl(remoteDataSource, tokenStorage);
});
