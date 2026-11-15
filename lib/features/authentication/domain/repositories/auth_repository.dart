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

  /// Saves a new name and email for the signed-in user. The phone can't change.
  Future<AuthUser> updateProfile(
    AuthUser current, {
    required String fullName,
    String? email,
  });

  /// Changes the signed-in user's password; the fingerprint login follows it.
  Future<void> changePassword(String current, String next);

  /// The phone has a fingerprint sensor with a fingerprint enrolled.
  Future<bool> biometricAvailable();

  /// Fingerprint sign-in is turned on for this phone.
  Future<bool> biometricEnabled();

  /// Turns fingerprint sign-in on: a fingerprint scan, then the server checks
  /// the password and issues this phone a revocable device token.
  /// False if the user cancelled the scan.
  Future<bool> enableBiometric(String password);

  Future<void> disableBiometric();

  /// Signs in with this phone's device token after a fingerprint scan.
  /// Null if the user cancelled the scan.
  Future<AuthUser?> signInWithBiometric();

  /// First-time login for an invited user, in three steps.
  Future<void> requestActivation(String username, String phone);
  Future<String> verifyActivation(String username, String phone, String code);
  Future<void> completeActivation(String activationToken, String password);
}
