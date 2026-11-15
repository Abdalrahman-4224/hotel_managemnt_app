import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class ProfileDataSource {
  final ApiClient apiClient;

  ProfileDataSource(this.apiClient);

  /// The signed-in user's hotel: name and room count.
  Future<Map<String, dynamic>> fetchCurrentHotel() async {
    final data = await apiClient.get('/hotels/current');
    return data;
  }

  /// The hotel's subscription. 403 without SUBSCRIPTION_VIEW.
  Future<Map<String, dynamic>> fetchSubscription() async {
    final data = await apiClient.get('/hotels/current/subscription');
    return data;
  }
}

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileDataSource(ref.watch(apiClientProvider));
});
