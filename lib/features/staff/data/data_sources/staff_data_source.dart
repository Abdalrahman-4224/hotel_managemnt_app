import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class StaffDataSource {
  final ApiClient apiClient;

  StaffDataSource(this.apiClient);

  /// The hotel's active staff with today's counts.
  Future<List<Map<String, dynamic>>> fetchStaff() async {
    final data = await apiClient.get('/users/staff');
    return List<Map<String, dynamic>>.from(data);
  }

  /// What one staff member did today.
  Future<List<Map<String, dynamic>>> fetchActivity(int userId) async {
    final data = await apiClient.get('/users/staff/$userId/activity');
    return List<Map<String, dynamic>>.from(data);
  }
}

final staffDataSourceProvider = Provider<StaffDataSource>((ref) {
  return StaffDataSource(ref.watch(apiClientProvider));
});
