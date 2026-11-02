import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/inventory_item.dart';

/// Converts items between the app and /inventory-items.
class InventoryItemModel {
  const InventoryItemModel._();

  static InventoryItem fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: parseInt(json['item_id'])!,
      name: json['item_name'] ?? '',
      category: json['category'] ?? '',
      // Quantities are NUMERIC columns, so they arrive as "84.00".
      quantity: (parseDouble(json['quantity_in_stock']) ?? 0).round(),
      minimum: (parseDouble(json['min_quantity']) ?? 0).round(),
      price: parseDouble(json['unit_price']) ?? 0,
    );
  }

  static Map<String, dynamic> newItemToJson(NewInventoryItem item) {
    return {
      'item_name': item.name,
      'category': item.category,
      'quantity_in_stock': item.quantity,
      'min_quantity': item.minimum,
      // unit_price is required by the table; the form doesn't ask for it.
      'unit_price': 0,
    };
  }
}
