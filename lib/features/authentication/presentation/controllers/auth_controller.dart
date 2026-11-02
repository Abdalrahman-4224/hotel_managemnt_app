import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  checking, // app just opened, reading the saved session
  loggedOut,
  loggedIn,
}

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthState(status: AuthStatus.checking);
  }

  /// On app start: if a user was saved from the last login, log them in.
  Future<void> _restoreSession() async {
    final user = await ref.read(authRepositoryProvider).getSavedUser();
    if (user == null) {
      state = const AuthState(status: AuthStatus.loggedOut);
    } else {
      state = AuthState(status: AuthStatus.loggedIn, user: user);
    }
  }

  Future<void> signIn(String username, String password) async {
    state = const AuthState(status: AuthStatus.loggedOut, isLoading: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(username, password);
      state = AuthState(status: AuthStatus.loggedIn, user: user);
    } on AppException catch (error) {
      state = AuthState(
        status: AuthStatus.loggedOut,
        errorMessage: error.message,
      );
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AuthState(status: AuthStatus.loggedOut);
  }

  /// Called by ApiClient when the server says the token is no longer valid.
  Future<void> sessionExpired() async {
    await ref.read(authRepositoryProvider).clearSession();
    state = const AuthState(status: AuthStatus.loggedOut);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
