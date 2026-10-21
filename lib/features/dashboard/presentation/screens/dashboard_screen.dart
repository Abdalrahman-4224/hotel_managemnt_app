import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/dashboard_local_data_source.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../widgets/section_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = const DashboardLocalDataSource().getSummary();
    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            subtitle: data.hotelLine,
            title: data.greeting,
            leading: const NzBrandMark(),
            actions: [
              NzIconButton(
                icon: LucideIcons.bell,
                tooltip: 'الإشعارات',
                showDot: true,
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                NzBottomNav.bodyPadding(context),
              ),
              children: [
                _RevenueCard(data: data),
                const SizedBox(height: 18),
                _StatsRow(data: data),
                const SizedBox(height: 18),
                const NzSectionTitle('الأقسام'),
                const SizedBox(height: 10),
                const _SectionsGrid(),
                const SizedBox(height: 18),
                NzSectionTitle(
                  'حركة اليوم',
                  actionLabel: 'عرض الكل',
                  onAction: () => context.go(AppRoutes.bookings),
                ),
                const SizedBox(height: 10),
                NzListCard(
                  children: [for (final m in data.movements) _MovementRow(m)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.data});

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    return NzInkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.wallet,
                size: 16,
                color: AppColors.goldLight,
              ),
              const SizedBox(width: 8),
              Text(
                'إيراد اليوم',
                style: AppText.body(13, color: AppColors.onInkMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              NzAmount(
                data.revenueUsd,
                'دولار',
                size: 32,
                color: Colors.white,
                unitColor: AppColors.onInkMuted,
                unitSize: 13,
              ),
              NzAmount(
                data.revenueIqd,
                'دينار',
                size: 20,
                color: AppColors.goldLight,
                unitColor: AppColors.onInkMuted,
                unitSize: 13,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const NzDivider(color: AppColors.onInkLine),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  data.revenueNote,
                  style: AppText.body(12.5, color: AppColors.onInkMuted),
                ),
              ),
              GestureDetector(
                onTap: () => context.go(AppRoutes.finance),
                child: Text(
                  'الحركات المالية',
                  style: AppText.body(
                    12.5,
                    weight: FontWeight.w500,
                    color: AppColors.goldLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.data});

  final DashboardSummary data;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: 'الإشغال',
              value: '${(data.occupancy * 100).round()}%',
              footer: NzProgressBar(value: data.occupancy),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              label: 'وصول اليوم',
              value: '${data.arrivals}',
              footer: Text(
                data.arrivalsNote,
                style: AppText.body(12, color: AppColors.inkFaint),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              label: 'مغادرة اليوم',
              value: '${data.departures}',
              footer: Text(
                data.departuresNote,
                style: AppText.body(12, color: AppColors.goldDeep),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.footer,
  });

  final String label;
  final String value;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
          const SizedBox(height: 8),
          Text(value, style: AppText.num(22, height: 1)),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }
}

class _SectionsGrid extends StatelessWidget {
  const _SectionsGrid();

  @override
  Widget build(BuildContext context) {
    final tiles = [
      SectionTile(
        featured: true,
        icon: LucideIcons.calendarPlus,
        title: 'إضافة حجز',
        subtitle: 'حجز فردي أو حملة',
        onTap: () => context.push(AppRoutes.addBooking),
      ),
      SectionTile(
        icon: LucideIcons.grid2x2,
        title: 'خريطة الغرف',
        subtitle: '23 متاحة من 84',
        onTap: () => context.go(AppRoutes.rooms),
      ),
      SectionTile(
        icon: LucideIcons.calendarCheck,
        title: 'سجل الحجوزات',
        subtitle: '14 حجزاً اليوم',
        onTap: () => context.go(AppRoutes.bookings),
      ),
      SectionTile(
        icon: LucideIcons.users,
        title: 'الحملات',
        subtitle: '3 حملات نشطة',
        onTap: () => context.go(AppRoutes.campaigns),
      ),
      SectionTile(
        icon: LucideIcons.listChecks,
        title: 'المهام',
        subtitle: '4 معلّقة · 1 متأخرة',
        onTap: () => context.go(AppRoutes.tasks),
      ),
      SectionTile(
        icon: LucideIcons.package,
        title: 'المخزن',
        subtitle: '5 أصناف تحت الحد',
        onTap: () => context.go(AppRoutes.inventory),
      ),
      SectionTile(
        icon: LucideIcons.wallet,
        title: 'الحركات المالية',
        subtitle: 'آخر حركة قبل ساعة',
        onTap: () => context.go(AppRoutes.finance),
      ),
      SectionTile(
        icon: LucideIcons.receipt,
        title: 'الفواتير',
        subtitle: '2 بانتظار التسوية',
        onTap: () => context.push(AppRoutes.invoice),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: 10),
                Expanded(child: tiles[i + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow(this.m);

  final DailyMovement m;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          NzInitialAvatar(m.initial),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.guest,
                  style: AppText.body(14.5, weight: FontWeight.w500),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'غرفة '),
                      TextSpan(
                        text: m.room,
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
              ],
            ),
          ),
          NzTag(
            m.tag,
            tone: switch (m.kind) {
              MovementKind.arrival => NzTagTone.gold,
              MovementKind.late => NzTagTone.dark,
              MovementKind.upcoming => NzTagTone.neutral,
            },
          ),
        ],
      ),
    );
  }
}
