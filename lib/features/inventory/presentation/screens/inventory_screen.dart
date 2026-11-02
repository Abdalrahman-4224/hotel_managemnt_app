import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../data/data_sources/inventory_catalog.dart';
import '../../domain/entities/inventory_item.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_sheets.dart';
import '../widgets/inventory_table.dart';

/// Stock list with category filters and a "below minimum" shortcut.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  static const _categories = InventoryCatalog.categories;
  var _items = const <InventoryItem>[];

  /// `all`, `low`, or a category name.
  var _filter = 'all';

  bool _matches(InventoryItem i, String f) =>
      f == 'all' || (f == 'low' ? i.isLow : i.category == f);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) showNzToast(context, errorText(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(inventoryControllerProvider);
    _items = async.value ?? const [];
    final low = _items.where((i) => i.isLow).toList();
    final rows = _items.where((i) => _matches(i, _filter)).toList();
    final filters = [
      ('all', 'الكل'),
      for (final c in _categories) (c.name, c.name),
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
                child: NzAsyncBody(
                  hasValue: async.hasValue,
                  error: async.error,
                  onRetry: () =>
                      ref.read(inventoryControllerProvider.notifier).refresh(),
                  child: () => RefreshIndicator(
                    onRefresh: () => ref
                        .read(inventoryControllerProvider.notifier)
                        .refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                                InventoryTable(items: rows, onOpen: _openItem),
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
                ),
              ),
            ],
          ),
          if (ref.watch(canProvider).can(Permissions.inventoryCreate))
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
                  if (item == null) return;
                  await _run(() async {
                    await ref
                        .read(inventoryControllerProvider.notifier)
                        .add(item);
                    setState(() => _filter = 'all');
                  });
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
      categoryName: item.category,
      suggested: math.max(10, item.minimum - item.quantity),
      canReceive: ref.read(canProvider).can(Permissions.inventoryUpdate),
    );
    if (added == null) return;
    await _run(
      () => ref.read(inventoryControllerProvider.notifier).receive(item, added),
    );
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
