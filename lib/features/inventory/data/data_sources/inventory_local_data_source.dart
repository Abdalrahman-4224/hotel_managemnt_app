import '../../domain/entities/inventory_item.dart';

/// Sample data from the design. Replace with an API data source.
class InventoryLocalDataSource {
  const InventoryLocalDataSource();

  List<InventoryCategory> getCategories() => const [
    InventoryCategory('cln', 'تنظيف', [
      'مناشف',
      'أكياس قمامة',
      'منظّف أرضيات',
      'معطّر جو',
      'قفازات',
    ]),
    InventoryCategory('mnt', 'صيانة', [
      'صنبور مياه',
      'مصابيح LED',
      'فلتر تكييف',
      'أسلاك كهرباء',
    ]),
    InventoryCategory('csm', 'مستهلكات', [
      'شامبو',
      'صابون',
      'فرشاة أسنان',
      'مياه معبّأة',
    ]),
  ];

  List<InventoryItem> getItems() => const [
    InventoryItem(
      name: 'مناشف',
      categoryId: 'cln',
      quantity: 84,
      minimum: 20,
      unitPrice: '15 \$',
    ),
    InventoryItem(
      name: 'صنبور مياه',
      categoryId: 'mnt',
      quantity: 6,
      minimum: 10,
      unitPrice: '90 \$',
    ),
    InventoryItem(
      name: 'شامبو',
      categoryId: 'csm',
      quantity: 0,
      minimum: 30,
      unitPrice: '5,200 د.ع',
    ),
    InventoryItem(
      name: 'أكياس قمامة',
      categoryId: 'cln',
      quantity: 240,
      minimum: 50,
      unitPrice: '1,300 د.ع',
    ),
    InventoryItem(
      name: 'مصابيح LED',
      categoryId: 'mnt',
      quantity: 22,
      minimum: 15,
      unitPrice: '4 \$',
    ),
  ];
}
