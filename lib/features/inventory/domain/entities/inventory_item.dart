enum StockLevel { good, low, out }

extension StockLevelLabel on StockLevel {
  String get label => switch (this) {
    StockLevel.good => 'جيدة',
    StockLevel.low => 'منخفضة',
    StockLevel.out => 'نفدت',
  };
}

/// A stock category with the product types the manager allows in it.
class InventoryCategory {
  const InventoryCategory(this.id, this.name, this.types);

  final String id;
  final String name;
  final List<String> types;
}

class InventoryItem {
  const InventoryItem({
    required this.name,
    required this.categoryId,
    required this.quantity,
    required this.minimum,
    required this.unitPrice,
  });

  final String name;
  final String categoryId;
  final int quantity;
  final int minimum;
  final String unitPrice;

  bool get isLow => quantity < minimum;

  StockLevel get level => quantity == 0
      ? StockLevel.out
      : isLow
      ? StockLevel.low
      : StockLevel.good;

  /// Fill of the stock bar: full at twice the minimum.
  double get fill => (quantity / (minimum * 2).clamp(1, 1 << 30)).clamp(0, 1);

  InventoryItem receive(int amount) => InventoryItem(
    name: name,
    categoryId: categoryId,
    quantity: quantity + amount,
    minimum: minimum,
    unitPrice: unitPrice,
  );
}
