import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class CampaignsDataSource {
  final ApiClient apiClient;

  CampaignsDataSource(this.apiClient);

  /// Campaigns with their rooms, dates and money position.
  Future<List<Map<String, dynamic>>> fetchCampaigns() async {
    final data = await apiClient.get('/campaigns');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Checks in every booking of the campaign at once.
  Future<void> checkIn(int campaignId) async {
    await apiClient.post(
      '/bookings/checkIn',
      data: {'campaign_id': campaignId},
    );
  }

  Future<void> checkOut(int campaignId) async {
    await apiClient.post(
      '/bookings/checkOut',
      data: {'campaign_id': campaignId},
    );
  }
}

final campaignsDataSourceProvider = Provider<CampaignsDataSource>((ref) {
  return CampaignsDataSource(ref.watch(apiClientProvider));
});
