import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/campaign.dart';

class CampaignStatusTag extends StatelessWidget {
  const CampaignStatusTag(this.status, {super.key});

  final CampaignStatus status;

  @override
  Widget build(BuildContext context) => NzTag(
    status.label,
    fontSize: 12,
    tone: switch (status) {
      CampaignStatus.staying => NzTagTone.dark,
      CampaignStatus.upcoming => NzTagTone.gold,
      CampaignStatus.departed => NzTagTone.neutral,
    },
  );
}

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required this.campaign, required this.onTap});

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = campaign;
    return NzCard(
      radius: 22,
      shadow: AppShadows.card,
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: AppText.body(16, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '#'),
                          TextSpan(
                            text: c.id,
                            style: AppText.num(
                              12.5,
                              weight: FontWeight.w400,
                              color: AppColors.inkMuted,
                            ),
                          ),
                          TextSpan(text: ' · المسؤول: ${c.manager}'),
                        ],
                      ),
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CampaignStatusTag(c.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _MiniStat('الأفراد', '${c.heads}')),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat('الغرف', '${c.rooms.length}')),
              const SizedBox(width: 8),
              Expanded(child: _MiniStat('الليالي', '${c.nights}')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المدفوع من الإجمالي',
                style: AppText.body(12.5, color: AppColors.inkMuted),
              ),
              Text(
                '${c.paid.short} / ${c.total.short}',
                style: AppText.num(12.5, weight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 6),
          NzProgressBar(value: c.paidPercent / 100, height: 6),
          const SizedBox(height: 6),
          Text(
            c.paidPercent >= 100 ? 'مسدّدة بالكامل' : 'المتبقي ${c.due.short}',
            style: AppText.body(12.5, color: AppColors.goldDeep),
          ),
          const SizedBox(height: 14),
          const NzDivider(),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                size: 14,
                color: AppColors.inkMuted,
              ),
              const SizedBox(width: 6),
              Text(
                c.dateRange,
                style: AppText.num(
                  12.5,
                  weight: FontWeight.w400,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(11.5, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
          Text(value, style: AppText.num(17, height: 1)),
        ],
      ),
    );
  }
}
