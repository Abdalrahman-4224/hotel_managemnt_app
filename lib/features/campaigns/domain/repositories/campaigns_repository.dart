import '../entities/campaign.dart';

/// What the app can do with campaigns (group bookings).
/// The real implementation is in data/repositories/campaigns_repository_impl.dart.
abstract class CampaignsRepository {
  Future<List<Campaign>> getCampaigns();
  Future<void> checkIn(Campaign campaign);
  Future<void> checkOut(Campaign campaign);
}
