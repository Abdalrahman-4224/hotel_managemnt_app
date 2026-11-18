import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../notifications/presentation/controllers/push_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import 'biometric_controller.dart';

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
      _startPush();
    }
  }

  /// Hands this phone's push token to the server. Done on every sign-in and
  /// on every start with a saved session, which also refreshes the device's
  /// "last seen" there. Never allowed to fail a sign-in.
  void _startPush() {
    ref.read(pushServiceProvider).start();
  }

  Future<void> signIn(String username, String password) async {
    state = const AuthState(status: AuthStatus.loggedOut, isLoading: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(username, password);
      state = AuthState(status: AuthStatus.loggedIn, user: user);
      _startPush();
    } on AppException catch (error) {
      state = AuthState(
        status: AuthStatus.loggedOut,
        errorMessage: error.message,
      );
    }
  }

  /// Signs in with the saved login after a fingerprint scan. Cancelling the
  /// scan just leaves the login screen as it was.
  Future<void> signInWithBiometric() async {
    state = const AuthState(status: AuthStatus.loggedOut, isLoading: true);
    try {
      final user = await ref.read(authRepositoryProvider).signInWithBiometric();
      state = user == null
          ? const AuthState(status: AuthStatus.loggedOut)
          : AuthState(status: AuthStatus.loggedIn, user: user);
      if (user != null) _startPush();
    } on AppException catch (error) {
      // The saved login may have just been wiped (password changed elsewhere).
      ref.invalidate(biometricStatusProvider);
      state = AuthState(
        status: AuthStatus.loggedOut,
        errorMessage: error.message,
      );
    }
  }

  /// Saves a new name and email. Errors are rethrown so the form can show them.
  Future<void> updateProfile({required String fullName, String? email}) async {
    final updated = await ref
        .read(authRepositoryProvider)
        .updateProfile(state.user!, fullName: fullName, email: email);
    state = AuthState(status: AuthStatus.loggedIn, user: updated);
  }

  /// Errors are rethrown so the form can show them.
  Future<void> changePassword(String current, String next) {
    return ref.read(authRepositoryProvider).changePassword(current, next);
  }

  /// Turns fingerprint sign-in on for the signed-in user. False if the scan
  /// was cancelled; errors (e.g. a wrong password) are rethrown.
  Future<bool> enableBiometric(String password) {
    return ref.read(authRepositoryProvider).enableBiometric(password);
  }

  Future<void> disableBiometric() {
    return ref.read(authRepositoryProvider).disableBiometric();
  }

  Future<void> signOut() async {
    // Withdraw the device while the token still authenticates: once the
    // session is cleared the server would refuse the request.
    await ref.read(pushServiceProvider).stop();
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

/// The signed-in user's id, or null when nobody is.
///
/// Every provider holding this user's data watches it, so signing out (or a
/// superadmin switching hotel) drops what the last one loaded instead of
/// showing it to the next.
final signedInUserIdProvider = Provider<int?>(
  (ref) => ref.watch(authControllerProvider.select((state) => state.user?.id)),
);
