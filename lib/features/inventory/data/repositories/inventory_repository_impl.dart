import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../data_sources/inventory_data_source.dart';
import '../models/inventory_item_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDataSource dataSource;

  InventoryRepositoryImpl(this.dataSource);

  @override
  Future<List<InventoryItem>> getItems() async {
    final rows = await dataSource.fetchItems();
    return rows.map(InventoryItemModel.fromJson).toList();
  }

  @override
  Future<void> addItem(NewInventoryItem item) {
    return dataSource.createItem(InventoryItemModel.newItemToJson(item));
  }

  @override
  Future<void> receive(InventoryItem item, int amount) {
    return dataSource.updateItem(item.id, {
      'quantity_in_stock': item.quantity + amount,
    });
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(ref.watch(inventoryDataSourceProvider));
});
