import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class InventoryDataSource {
  final ApiClient apiClient;

  InventoryDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchItems() async {
    final data = await apiClient.get('/inventory-items');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createItem(Map<String, dynamic> body) async {
    await apiClient.post('/inventory-items', data: body);
  }

  Future<void> updateItem(int itemId, Map<String, dynamic> body) async {
    await apiClient.put('/inventory-items/$itemId', data: body);
  }
}

final inventoryDataSourceProvider = Provider<InventoryDataSource>((ref) {
  return InventoryDataSource(ref.watch(apiClientProvider));
});
