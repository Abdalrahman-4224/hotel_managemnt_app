import '../../../../core/utils/formatters.dart';

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
  const InventoryCategory(this.name, this.types);

  final String name;
  final List<String> types;
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimum,
    required this.price,
  });

  final int id;
  final String name;

  /// Category name, e.g. "تنظيف".
  final String category;
  final int quantity;
  final int minimum;
  final double price;

  String get unitPrice => price > 0 ? fmtNum(price) : '—';

  bool get isLow => quantity < minimum;

  StockLevel get level => quantity == 0
      ? StockLevel.out
      : isLow
      ? StockLevel.low
      : StockLevel.good;

  /// Fill of the stock bar: full at twice the minimum.
  double get fill => (quantity / (minimum * 2).clamp(1, 1 << 30)).clamp(0, 1);
}

/// What the new-item form collects.
class NewInventoryItem {
  const NewInventoryItem({
    required this.name,
    required this.category,
    required this.quantity,
    required this.minimum,
  });

  final String name;
  final String category;
  final int quantity;
  final int minimum;
}
