import '../entities/profile.dart';

/// The hotel's account.
/// The real implementation is in data/repositories/profile_repository_impl.dart.
abstract class ProfileRepository {
  /// The signed-in user's hotel. Any staff member may read it.
  Future<Hotel> getHotel();

  /// The hotel's subscription. Needs SUBSCRIPTION_VIEW.
  Future<Subscription> getSubscription();
}
