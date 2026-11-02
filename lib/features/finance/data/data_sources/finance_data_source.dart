import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class FinanceDataSource {
  final ApiClient apiClient;

  FinanceDataSource(this.apiClient);

  /// All money movements, with the name of who recorded each one.
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final data = await apiClient.get('/transactions');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createTransaction(Map<String, dynamic> body) async {
    await apiClient.post('/transactions', data: body);
  }
}

final financeDataSourceProvider = Provider<FinanceDataSource>((ref) {
  return FinanceDataSource(ref.watch(apiClientProvider));
});
