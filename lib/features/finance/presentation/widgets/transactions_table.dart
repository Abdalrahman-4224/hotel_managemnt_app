import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/finance_transaction.dart';
import '../controllers/finance_controller.dart';

/// Date-grouped list of transactions (used inline and full-screen).
class TransactionsTable extends StatelessWidget {
  const TransactionsTable({
    super.key,
    required this.groups,
    required this.onOpen,
  });

  final List<TxGroup> groups;
  final ValueChanged<FinanceTransaction> onOpen;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return NzDashedBox(
        child: Text(
          'لا حركات بهذا الفلتر.',
          textAlign: TextAlign.center,
          style: AppText.body(14, color: AppColors.inkMuted),
        ),
      );
    }
    return NzCard(
      radius: 18,
      shadow: AppShadows.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var g = 0; g < groups.length; g++) ...[
            _GroupHeader(group: groups[g], first: g == 0),
            for (var i = 0; i < groups[g].items.length; i++) ...[
              if (i > 0) const NzDivider(),
              TransactionRow(
                tx: groups[g].items[i],
                onTap: () => onOpen(groups[g].items[i]),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group, required this.first});

  final TxGroup group;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border(
          top: first
              ? BorderSide.none
              : const BorderSide(color: Color(0x141C1B19)),
          bottom: const BorderSide(color: AppColors.line),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              group.date,
              style: AppText.num(12.5, color: AppColors.ink3, height: 1),
            ),
          ),
          Text(
            group.countLabel,
            style: AppText.body(12, color: AppColors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.tx, required this.onTap});

  final FinanceTransaction tx;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inc = tx.isIncome;
    return Semantics(
      button: true,
      label:
          '${tx.kind.label} — ${tx.reference} — ${tx.signedAmount} ${tx.currency.label}',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: inc ? AppColors.goldTint : AppColors.inert,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: inc
                          ? AppColors.goldBorderSoft
                          : const Color(0x0F1C1B19),
                    ),
                  ),
                  child: Icon(
                    inc ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                    size: 17,
                    color: inc ? AppColors.goldDeep : AppColors.inkMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.reference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(14.5, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${tx.staff} · ${tx.method.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(12, color: AppColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx.signedAmount,
                      textDirection: TextDirection.ltr,
                      style: AppText.num(
                        15,
                        height: 1.3,
                        color: inc ? AppColors.goldDarkest : AppColors.ink,
                      ),
                    ),
                    Text(
                      tx.currency.label,
                      style: AppText.body(11, color: AppColors.inkFaint),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Icon(
                  LucideIcons.chevronLeft,
                  size: 15,
                  color: AppColors.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kind segmented control + filter button with an active-count badge.
class FinanceToolbar extends StatelessWidget {
  const FinanceToolbar({
    super.key,
    required this.controller,
    required this.onFilter,
  });

  final FinanceController controller;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final active = controller.activeFilters.length;
    return Row(
      children: [
        Expanded(
          child: NzSegmented<TxKind?>(
            selected: controller.filter.kind,
            onChanged: controller.setKind,
            segments: [
              NzSegment(null, 'الكل', count: '${controller.countFor(null)}'),
              NzSegment(
                TxKind.income,
                'إيراد',
                count: '${controller.countFor(TxKind.income)}',
              ),
              NzSegment(
                TxKind.expense,
                'مصروف',
                count: '${controller.countFor(TxKind.expense)}',
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        NzIconButton(
          icon: LucideIcons.slidersHorizontal,
          tooltip: active > 0 ? 'فلترة — $active فلاتر مفعّلة' : 'فلترة',
          size: 52,
          radius: 16,
          background: active > 0 ? AppColors.goldTint : AppColors.card,
          borderColor: active > 0 ? AppColors.goldDeep : AppColors.lineStrong,
          borderWidth: active > 0 ? 1.5 : 1,
          iconColor: active > 0 ? AppColors.goldDarkest : AppColors.ink3,
          badge: active > 0 ? '$active' : null,
          onPressed: onFilter,
        ),
      ],
    );
  }
}
