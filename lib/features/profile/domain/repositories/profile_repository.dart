import '../entities/profile.dart';

/// The hotel's account.
/// The real implementation is in data/repositories/profile_repository_impl.dart.
abstract class ProfileRepository {
  Future<Subscription> getSubscription();
}
