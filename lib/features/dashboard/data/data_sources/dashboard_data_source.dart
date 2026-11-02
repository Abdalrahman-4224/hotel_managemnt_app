import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class DashboardDataSource {
  final ApiClient apiClient;

  DashboardDataSource(this.apiClient);

  /// `{ revenue_today: [{currency, total, count}], total_rooms, occupied_rooms, movements: [...] }`
  Future<Map<String, dynamic>> fetchSummary() async {
    final data = await apiClient.get('/dashboard');
    return data;
  }
}

final dashboardDataSourceProvider = Provider<DashboardDataSource>((ref) {
  return DashboardDataSource(ref.watch(apiClientProvider));
});
