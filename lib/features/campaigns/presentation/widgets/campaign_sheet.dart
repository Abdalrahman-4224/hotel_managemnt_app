import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/campaign.dart';
import 'campaign_card.dart';

/// Full campaign details: facts, money position, rooms.
/// [onAction] runs the main button (check in / check out); it is hidden when
/// [canAct] is false.
Future<void> showCampaignSheet(
  BuildContext context,
  Campaign c, {
  required VoidCallback onAction,
  required bool canAct,
}) {
  return showNzTallSheet<void>(
    context,
    header: (ctx) => Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'حملة #'),
                    TextSpan(
                      text: '${c.id}',
                      style: AppText.num(
                        12.5,
                        weight: FontWeight.w400,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                style: AppText.body(12.5, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 2),
              Text(c.name, style: AppText.display(21)),
            ],
          ),
        ),
        CampaignStatusTag(c.status),
      ],
    ),
    body: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NzGrid(
          columns: 2,
          children: [
            NzFact('مسؤول الحملة', c.manager),
            NzFact('الهاتف', c.phone),
            NzFact('الدخول', fmtDate(c.checkIn)),
            NzFact('الخروج', fmtDate(c.checkOut)),
            NzFact('الأفراد', '${c.heads}'),
            NzFact('الليالي', '${c.nights}'),
          ],
        ),
        const SizedBox(height: 16),
        _MoneyCard(c),
        const SizedBox(height: 16),
        Text('غرف الحملة', style: AppText.display(16, height: 1.4)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final r in c.rooms)
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(r, style: AppText.num(14, height: 1)),
                ),
              ),
          ],
        ),
      ],
    ),
    footer: (ctx) => canAct
        ? NzPrimaryButton(
            label: c.status.action,
            fontSize: 14.5,
            onPressed: () {
              Navigator.of(ctx).pop();
              onAction();
            },
          )
        : NzOutlineButton(
            label: 'إغلاق',
            height: 54,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
  );
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard(this.c);

  final Campaign c;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('الإجمالي', c.total),
      ('المدفوع', c.paid),
      ('المتبقي', c.due),
    ];
    // Booking amounts are in US dollars.
    return NzCard(
      color: AppColors.ink,
      borderColor: null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الموقف المالي',
            style: AppText.body(12.5, color: AppColors.onInkMuted),
          ),
          for (final (k, v) in rows) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    k,
                    style: AppText.body(13.5, color: AppColors.onInkMuted),
                  ),
                ),
                NzAmount(
                  fmtNum(v),
                  'دولار',
                  size: 16,
                  color: AppColors.onInk,
                  unitColor: AppColors.onInkMuted,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
