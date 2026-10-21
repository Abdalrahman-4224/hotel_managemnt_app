import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/campaign.dart';
import 'campaign_card.dart';

/// Full campaign details: facts, money position, rooms, members, history.
Future<void> showCampaignSheet(BuildContext context, Campaign c) {
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
                      text: c.id,
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
            NzFact('الدخول', c.checkIn),
            NzFact('الخروج', c.checkOut),
            NzFact('أساس السعر', c.priceBasis),
            NzFact('المستند', c.document),
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
        if (c.members.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('الأفراد', style: AppText.display(16, height: 1.4)),
          for (final m in c.members) ...[
            const SizedBox(height: 8),
            _MemberRow(m),
          ],
        ],
        const SizedBox(height: 16),
        Text('سجل الحملة', style: AppText.display(16, height: 1.4)),
        const SizedBox(height: 10),
        for (final t in c.trail) _TrailItem(t),
      ],
    ),
    footer: (ctx) => Row(
      children: [
        Expanded(
          child: NzOutlineButton(
            label: 'تعديل التوزيع',
            height: 54,
            fontSize: 14.5,
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NzPrimaryButton(
            label: c.status.action,
            fontSize: 14.5,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ),
      ],
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
                  v.usd,
                  'دولار',
                  size: 16,
                  color: AppColors.onInk,
                  unitColor: AppColors.onInkMuted,
                ),
                const SizedBox(width: 10),
                NzAmount(
                  v.iqd,
                  'دينار',
                  size: 15,
                  color: AppColors.goldLight,
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

class _MemberRow extends StatelessWidget {
  const _MemberRow(this.m);

  final CampaignMember m;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          NzInitialAvatar(m.initial, size: 34, fontSize: 13),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.name, style: AppText.body(14, weight: FontWeight.w500)),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'غرفة '),
                      TextSpan(
                        text: m.room,
                        style: AppText.num(
                          12,
                          weight: FontWeight.w400,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: m.nights,
                        style: AppText.num(
                          12,
                          weight: FontWeight.w400,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const TextSpan(text: ' ليالٍ'),
                    ],
                  ),
                  style: AppText.body(12, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          Text(m.amount, style: AppText.num(13.5, height: 1)),
        ],
      ),
    );
  }
}

class _TrailItem extends StatelessWidget {
  const _TrailItem(this.t);

  final CampaignEvent t;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(width: 1.5, color: AppColors.goldBorderSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.what, style: AppText.body(14, height: 1.5)),
                  Text(
                    t.when,
                    style: AppText.body(12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
