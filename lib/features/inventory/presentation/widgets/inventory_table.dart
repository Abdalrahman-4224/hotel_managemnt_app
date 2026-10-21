import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/inventory_item.dart';

class StockLevelTag extends StatelessWidget {
  const StockLevelTag(this.level, {super.key, this.small = true});

  final StockLevel level;
  final bool small;

  @override
  Widget build(BuildContext context) => NzTag(
    level.label,
    height: small ? 24 : 26,
    fontSize: small ? 11.5 : 12,
    tone: switch (level) {
      StockLevel.out => NzTagTone.dark,
      StockLevel.low => NzTagTone.gold,
      StockLevel.good => NzTagTone.neutral,
    },
  );
}

class InventoryTable extends StatelessWidget {
  const InventoryTable({
    super.key,
    required this.items,
    required this.categoryName,
    required this.onOpen,
  });

  final List<InventoryItem> items;
  final String Function(String id) categoryName;
  final ValueChanged<InventoryItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 18,
      shadow: AppShadows.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NzTableHead(
            cells: [
              ('المادة · القسم', 1, null, TextAlign.start),
              ('الحالة', null, 72, TextAlign.start),
              ('الكمية / الحد', null, 84, TextAlign.end),
            ],
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const NzDivider(),
            _Row(
              item: items[i],
              category: categoryName(items[i].categoryId),
              onTap: () => onOpen(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.category, required this.onTap});

  final InventoryItem item;
  final String category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final good = item.level == StockLevel.good;
    return Semantics(
      button: true,
      label: item.name,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: good ? null : const Color(0xFFFFFAF0),
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppText.body(14.5, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$category · '),
                          TextSpan(
                            text: item.unitPrice,
                            style: AppText.num(
                              12,
                              weight: FontWeight.w400,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                      style: AppText.body(12, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 72,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: StockLevelTag(item.level),
                ),
              ),
              SizedBox(
                width: 84,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${item.quantity} '),
                          TextSpan(
                            text: '/ ${item.minimum}',
                            style: AppText.num(
                              12,
                              weight: FontWeight.w400,
                              color: AppColors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                      textDirection: TextDirection.ltr,
                      style: AppText.num(15, height: 1.2),
                    ),
                    const SizedBox(height: 6),
                    NzProgressBar(
                      value: item.fill,
                      height: 4,
                      fill: good ? AppColors.inkFaint : AppColors.gold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
