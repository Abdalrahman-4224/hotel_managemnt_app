import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/entities/inventory_item.dart';

/// Loads the stock list. Actions call the server, then reload. Errors are rethrown.
class InventoryController extends AsyncNotifier<List<InventoryItem>> {
  @override
  Future<List<InventoryItem>> build() {
    return ref.read(inventoryRepositoryProvider).getItems();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(inventoryRepositoryProvider).getItems(),
    );
  }

  Future<void> add(NewInventoryItem item) async {
    await ref.read(inventoryRepositoryProvider).addItem(item);
    await refresh();
  }

  Future<void> receive(InventoryItem item, int amount) async {
    await ref.read(inventoryRepositoryProvider).receive(item, amount);
    await refresh();
  }
}

final inventoryControllerProvider =
    AsyncNotifierProvider<InventoryController, List<InventoryItem>>(
      InventoryController.new,
    );
