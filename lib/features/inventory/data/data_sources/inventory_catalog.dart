import '../../domain/entities/inventory_item.dart';

/// The stock categories and the product types allowed in each.
/// The server stores the category as text on each item and has no list of
/// allowed types, so this list lives in the app.
class InventoryCatalog {
  const InventoryCatalog._();

  static const categories = [
    InventoryCategory('تنظيف', [
      'مناشف',
      'أكياس قمامة',
      'منظّف أرضيات',
      'معطّر جو',
      'قفازات',
    ]),
    InventoryCategory('صيانة', [
      'صنبور مياه',
      'مصابيح LED',
      'فلتر تكييف',
      'أسلاك كهرباء',
    ]),
    InventoryCategory('مستهلكات', [
      'شامبو',
      'صابون',
      'فرشاة أسنان',
      'مياه معبّأة',
    ]),
  ];
}
