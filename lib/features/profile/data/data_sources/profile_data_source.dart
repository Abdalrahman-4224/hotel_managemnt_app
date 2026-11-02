import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class ProfileDataSource {
  final ApiClient apiClient;

  ProfileDataSource(this.apiClient);

  /// The signed-in user's hotel, with its subscription dates and room count.
  Future<Map<String, dynamic>> fetchCurrentHotel() async {
    final data = await apiClient.get('/hotels/current');
    return data;
  }
}

final profileDataSourceProvider = Provider<ProfileDataSource>((ref) {
  return ProfileDataSource(ref.watch(apiClientProvider));
});
