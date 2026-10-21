import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/inventory_item.dart';
import 'inventory_table.dart';

/// Item details with a purchase-receipt stepper. Resolves to the quantity
/// received, or null when closed.
Future<int?> showItemSheet(
  BuildContext context, {
  required InventoryItem item,
  required String categoryName,
  required int suggested,
}) {
  var add = suggested;
  return showNzSheet<int>(
    context,
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(item.name, style: AppText.display(21)),
                  ],
                ),
              ),
              StockLevelTag(item.level, small: false),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (i, (k, v)) in [
                ('الكمية', '${item.quantity}'),
                ('الحد الأدنى', '${item.minimum}'),
                ('سعر الوحدة', item.unitPrice),
              ].indexed) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _NumFact(k, v)),
              ],
            ],
          ),
          const SizedBox(height: 14),
          NzCard(
            radius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'إدخال مشتريات',
                    style: AppText.body(14.5, weight: FontWeight.w500),
                  ),
                ),
                NzStepButton(
                  label: '−',
                  tooltip: 'إنقاص',
                  onTap: () => setSheet(() => add = math.max(1, add - 1)),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '$add',
                    textAlign: TextAlign.center,
                    style: AppText.num(20, height: 1),
                  ),
                ),
                NzStepButton(
                  label: '+',
                  tooltip: 'زيادة',
                  dark: true,
                  onTap: () => setSheet(() => add++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: NzOutlineButton(
                  label: 'إغلاق',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: NzPrimaryButton(
                  label: 'إدخال $add إلى المخزن',
                  height: 52,
                  fontSize: 15,
                  onPressed: () => Navigator.of(ctx).pop(add),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _NumFact extends StatelessWidget {
  const _NumFact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
          Text(value, style: AppText.num(16, height: 1.2)),
        ],
      ),
    );
  }
}

class _NewItemDraft extends ChangeNotifier {
  InventoryCategory? category;
  String? type;
  final qty = TextEditingController(text: '0');
  final min = TextEditingController(text: '0');

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  InventoryItem? build() => type == null
      ? null
      : InventoryItem(
          name: type!,
          categoryId: category!.id,
          quantity: int.tryParse(qty.text) ?? 0,
          minimum: int.tryParse(min.text) ?? 0,
          unitPrice: '—',
        );

  @override
  void dispose() {
    qty.dispose();
    min.dispose();
    super.dispose();
  }
}

/// Adds a product type (from the manager's list) to the stock.
Future<InventoryItem?> showNewItemSheet(
  BuildContext context, {
  required List<InventoryCategory> categories,
  required Set<String> inStock,
}) {
  final d = _NewItemDraft();
  return showNzTallSheet<InventoryItem>(
    context,
    heightFactor: .9,
    shrinkWrap: true,
    header: (ctx) => Text('مادة جديدة في المخزن', style: AppText.display(21)),
    body: (ctx) => ListenableBuilder(
      listenable: d,
      builder: (ctx, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('القسم', style: AppText.body(13, color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in categories)
                NzChoicePill(
                  label: c.name,
                  selected: d.category == c,
                  onTap: () => d.update(() {
                    d.category = c;
                    d.type = null;
                  }),
                ),
            ],
          ),
          if (d.category != null) ...[
            const SizedBox(height: 16),
            Text(
              'نوع المنتج — من قائمة مدير الفندق',
              style: AppText.body(13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 8),
            NzGrid(
              columns: 2,
              children: [
                for (final t in d.category!.types)
                  _TypeOption(
                    label: t,
                    used: inStock.contains(t),
                    selected: d.type == t,
                    onTap: () => d.update(() => d.type = t),
                  ),
              ],
            ),
          ],
          if (d.type != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _QtyField('الكمية الابتدائية', d.qty)),
                const SizedBox(width: 10),
                Expanded(child: _QtyField('الحد الأدنى', d.min)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.goldTint,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldBorderSoft),
            ),
            child: Text(
              'الأقسام والأنواع يحدّدها مدير الفندق، والنوع الموجود في المخزن لا يُضاف مرة ثانية.',
              style: AppText.body(
                13,
                color: AppColors.goldDarkest,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    ),
    footer: (ctx) => ListenableBuilder(
      listenable: d,
      builder: (ctx, _) => Row(
        children: [
          Expanded(
            child: NzOutlineButton(
              label: 'إلغاء',
              height: 54,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: NzPrimaryButton(
              label: 'إضافة المادة',
              disabled: d.type == null,
              onPressed: () => Navigator.of(ctx).pop(d.build()),
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(() => Future.delayed(const Duration(seconds: 1), d.dispose));
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.used,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool used;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = used
        ? AppColors.inkFaint
        : selected
        ? AppColors.goldDarkest
        : AppColors.ink;
    return GestureDetector(
      onTap: used ? null : onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: used
              ? AppColors.inert
              : selected
              ? AppColors.goldTint
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.goldDeep : AppColors.lineStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppText.body(14.5, weight: FontWeight.w500, color: fg),
            ),
            const SizedBox(height: 3),
            Text(
              used ? 'موجودة في المخزن' : 'متاحة للإضافة',
              style: AppText.body(11.5, color: fg.withValues(alpha: .8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  const _QtyField(this.label, this.controller);

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return NzTextField(
      label: label,
      controller: controller,
      height: 50,
      radius: 14,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: AppText.num(16),
    );
  }
}
