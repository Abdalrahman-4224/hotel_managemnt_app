import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/inventory_local_data_source.dart';
import '../../domain/entities/inventory_item.dart';
import '../widgets/inventory_sheets.dart';
import '../widgets/inventory_table.dart';

/// Stock list with category filters and a "below minimum" shortcut.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static const _source = InventoryLocalDataSource();
  final _categories = _source.getCategories();
  var _items = _source.getItems();

  /// `all`, `low`, or a category id.
  var _filter = 'all';

  bool _matches(InventoryItem i, String f) =>
      f == 'all' || (f == 'low' ? i.isLow : i.categoryId == f);

  String _categoryName(String id) =>
      _categories.where((c) => c.id == id).firstOrNull?.name ?? '—';

  @override
  Widget build(BuildContext context) {
    final low = _items.where((i) => i.isLow).toList();
    final rows = _items.where((i) => _matches(i, _filter)).toList();
    final filters = [
      ('all', 'الكل'),
      for (final c in _categories) (c.id, c.name),
      ('low', 'تحت الحد'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle:
                    '${_items.length} مواد · ${low.length} تحت الحد الأدنى',
                title: 'المخزن',
                actions: [
                  NzIconButton(
                    icon: LucideIcons.arrowLeftRight,
                    tooltip: 'حركات الصرف',
                    onPressed: () {},
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 14,
                    bottom: NzBottomNav.bodyPadding(context) + 76,
                  ),
                  children: [
                    if (low.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        child: _LowStockBanner(
                          items: low,
                          onShow: () => setState(() => _filter = 'low'),
                        ),
                      ),
                    NzPillScroller(
                      gap: 6,
                      children: [
                        for (final (k, l) in filters)
                          NzChoicePill(
                            label: l,
                            count:
                                '${_items.where((i) => _matches(i, k)).length}',
                            selected: _filter == k,
                            height: 38,
                            horizontalPadding: 12,
                            fontSize: 13,
                            onTap: () => setState(() => _filter = k),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (rows.isNotEmpty) ...[
                            InventoryTable(
                              items: rows,
                              categoryName: _categoryName,
                              onOpen: _openItem,
                            ),
                            const SizedBox(height: 14),
                          ],
                          Text(
                            'كل صرف مرتبط بمهمة، ويُخصم من الرصيد لحظة إتمامها.',
                            textAlign: TextAlign.center,
                            style: AppText.body(
                              12.5,
                              color: AppColors.inkFaint,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PositionedDirectional(
            end: 16,
            bottom: NzBottomNav.fabBottom(context),
            child: NzFloatingButton(
              label: 'مادة جديدة',
              onPressed: () async {
                final item = await showNewItemSheet(
                  context,
                  categories: _categories,
                  inStock: {for (final i in _items) i.name},
                );
                if (item != null) {
                  setState(() {
                    _items = [..._items, item];
                    _filter = 'all';
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openItem(InventoryItem item) async {
    final added = await showItemSheet(
      context,
      item: item,
      categoryName: _categoryName(item.categoryId),
      suggested: math.max(10, item.minimum - item.quantity),
    );
    if (added != null) {
      setState(() {
        _items = [
          for (final i in _items) identical(i, item) ? i.receive(added) : i,
        ];
      });
    }
  }
}

class _LowStockBanner extends StatelessWidget {
  const _LowStockBanner({required this.items, required this.onShow});

  final List<InventoryItem> items;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    final style = AppText.body(
      13,
      weight: FontWeight.w500,
      color: AppColors.goldDarkest,
      height: 1.3,
    );
    return Semantics(
      button: true,
      label: '${items.length} مواد تحت الحد الأدنى — عرضها',
      child: GestureDetector(
        onTap: onShow,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.goldTint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x66B68235)),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.triangleAlert,
                size: 16,
                color: AppColors.goldDeep,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${items.length} تحت الحد',
                        style: style.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' · ${items.map((i) => i.name).join('، ')}',
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: style,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'عرض',
                style: style.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.goldDarkest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
