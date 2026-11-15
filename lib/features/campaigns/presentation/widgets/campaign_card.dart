import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
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
      radius: AppRadius.r22,
      shadow: AppShadows.card,
      padding: EdgeInsets.all(AppSpacing.s16),
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
                    SizedBox(height: AppSpacing.s3),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '#'),
                          TextSpan(
                            text: '${c.id}',
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
              SizedBox(width: AppSpacing.s12),
              CampaignStatusTag(c.status),
            ],
          ),
          SizedBox(height: AppSpacing.s14),
          Row(
            children: [
              Expanded(child: _MiniStat('الأفراد', '${c.heads}')),
              SizedBox(width: AppSpacing.s8),
              Expanded(child: _MiniStat('الغرف', '${c.rooms.length}')),
              SizedBox(width: AppSpacing.s8),
              Expanded(child: _MiniStat('الليالي', '${c.nights}')),
            ],
          ),
          SizedBox(height: AppSpacing.s14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المدفوع من الإجمالي',
                style: AppText.body(12.5, color: AppColors.inkMuted),
              ),
              Text(
                '${fmtNum(c.paid)} \$ / ${fmtNum(c.total)} \$',
                style: AppText.num(12.5, weight: FontWeight.w400),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s6),
          NzProgressBar(value: (c.paidPercent / 100).clamp(0, 1), height: 6.r),
          SizedBox(height: AppSpacing.s6),
          Text(
            c.paidPercent >= 100
                ? 'مسدّدة بالكامل'
                : 'المتبقي ${fmtNum(c.due)} \$',
            style: AppText.body(12.5, color: AppColors.goldDeep),
          ),
          SizedBox(height: AppSpacing.s14),
          const NzDivider(),
          SizedBox(height: AppSpacing.s10),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14.r, color: AppColors.inkMuted),
              SizedBox(width: AppSpacing.s6),
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
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s8,
      ),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(11.5, color: AppColors.inkMuted)),
          SizedBox(height: AppSpacing.s3),
          Text(value, style: AppText.num(17, height: 1)),
        ],
      ),
    );
  }
}
