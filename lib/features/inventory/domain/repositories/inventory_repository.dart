import '../entities/inventory_item.dart';

/// What the app can do with stock.
/// The real implementation is in data/repositories/inventory_repository_impl.dart.
abstract class InventoryRepository {
  Future<List<InventoryItem>> getItems();
  Future<void> addItem(NewInventoryItem item);

  /// A purchase came in: add [amount] to the stock.
  Future<void> receive(InventoryItem item, int amount);
}
