import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../bookings/presentation/controllers/bookings_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../rooms/presentation/controllers/floors_controller.dart';
import '../../data/repositories/campaigns_repository_impl.dart';
import '../../domain/entities/campaign.dart';

/// Loads the campaigns list. Check-in / check-out reload it afterwards.
class CampaignsController extends AsyncNotifier<List<Campaign>> {
  @override
  Future<List<Campaign>> build() {
    return ref.read(campaignsRepositoryProvider).getCampaigns();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(campaignsRepositoryProvider).getCampaigns(),
    );
  }

  /// The main action for the campaign's status. Errors are rethrown.
  Future<void> nextStep(Campaign campaign) async {
    final repository = ref.read(campaignsRepositoryProvider);
    switch (campaign.status) {
      case CampaignStatus.upcoming:
        await repository.checkIn(campaign);
      case CampaignStatus.staying:
        await repository.checkOut(campaign);
      case CampaignStatus.departed:
        return;
    }
    // Rooms and bookings changed too.
    ref.invalidate(floorsControllerProvider);
    ref.invalidate(bookingsControllerProvider);
    ref.invalidate(dashboardProvider);
    await refresh();
  }
}

final campaignsControllerProvider =
    AsyncNotifierProvider<CampaignsController, List<Campaign>>(
      CampaignsController.new,
    );
