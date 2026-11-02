import '../entities/auth_user.dart';
import '../entities/permissions.dart';

/// What the app can do with authentication.
/// The real implementation is in data/repositories/auth_repository_impl.dart.
abstract class AuthRepository {
  /// Signs in and saves the session on the device.
  Future<AuthUser> signIn(String username, String password);

  /// Signs out on the server and removes the saved session.
  Future<void> signOut();

  /// The user saved from the last login, or null if there is none.
  Future<AuthUser?> getSavedUser();

  /// Removes the saved session without calling the server.
  Future<void> clearSession();

  /// What the signed-in user is allowed to do.
  Future<Permissions> getPermissions();

  /// First-time login for an invited user, in three steps.
  Future<void> requestActivation(String username, String phone);
  Future<String> verifyActivation(String username, String phone, String code);
  Future<void> completeActivation(String activationToken, String password);
}
