import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../../profile/presentation/controllers/subscription_controller.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/section_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(String? fullName) {
    final hello = DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';
    final first = (fullName ?? '').split(' ').first;
    return first.isEmpty ? hello : '$hello، $first';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final can = ref.watch(canProvider);
    final user = ref.watch(authControllerProvider).user;
    final hotel = ref.watch(subscriptionProvider).value?.hotelName ?? '';
    // Without DASHBOARD_VIEW the summary endpoint returns 403, so don't ask
    // for it at all - just show the sections this user can open.
    final showSummary = can.can(Permissions.dashboardView);
    final async = showSummary
        ? ref.watch(dashboardProvider)
        : const AsyncValue<DashboardSummary?>.data(null);
    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            subtitle: hotel,
            title: _greeting(user?.fullName),
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
            child: NzAsyncBody(
              hasValue: async.hasValue,
              error: async.error,
              onRetry: () => ref.invalidate(dashboardProvider),
              child: () => RefreshIndicator(
                onRefresh: () async {
                  if (!showSummary) return;
                  ref.invalidate(dashboardProvider);
                  await ref.read(dashboardProvider.future);
                },
                child: _body(context, async.value, can),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [data] is null when the user may not see the summary.
  Widget _body(BuildContext context, DashboardSummary? data, Permissions can) {
    final showMovements = data != null && can.can(Permissions.bookingView);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        NzBottomNav.bodyPadding(context),
      ),
      children: [
        if (data != null) ...[
          _RevenueCard(data: data),
          const SizedBox(height: 18),
          _StatsRow(data: data),
          const SizedBox(height: 18),
        ],
        const NzSectionTitle('الأقسام'),
        const SizedBox(height: 10),
        _SectionsGrid(can: can),
        if (showMovements) ...[
          const SizedBox(height: 18),
          NzSectionTitle(
            'حركة اليوم',
            actionLabel: 'عرض الكل',
            onAction: () => context.go(AppRoutes.bookings),
          ),
          const SizedBox(height: 10),
          if (data.movements.isEmpty)
            NzDashedBox(
              child: Text(
                'لا وصول ولا مغادرة اليوم.',
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.inkMuted),
              ),
            )
          else
            NzListCard(
              children: [for (final m in data.movements) _MovementRow(m)],
            ),
        ],
      ],
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
  const _SectionsGrid({required this.can});

  final Permissions can;

  @override
  Widget build(BuildContext context) {
    // Each tile needs its permission; the rest are left out of the grid.
    final tiles = [
      if (can.can(Permissions.bookingCreate))
        SectionTile(
          featured: true,
          icon: LucideIcons.calendarPlus,
          title: 'إضافة حجز',
          subtitle: 'حجز فردي أو حملة',
          onTap: () => context.push(AppRoutes.addBooking),
        ),
      if (can.can(Permissions.roomView))
        SectionTile(
          icon: LucideIcons.grid2x2,
          title: 'خريطة الغرف',
          subtitle: 'حالة الغرف طابقاً بطابق',
          onTap: () => context.go(AppRoutes.rooms),
        ),
      if (can.can(Permissions.bookingView))
        SectionTile(
          icon: LucideIcons.calendarCheck,
          title: 'سجل الحجوزات',
          subtitle: 'الدخول والخروج والإلغاء',
          onTap: () => context.go(AppRoutes.bookings),
        ),
      if (can.can(Permissions.campaignView))
        SectionTile(
          icon: LucideIcons.users,
          title: 'الحملات',
          subtitle: 'الحجوزات الجماعية',
          onTap: () => context.go(AppRoutes.campaigns),
        ),
      if (can.can(Permissions.taskView))
        SectionTile(
          icon: LucideIcons.listChecks,
          title: 'المهام',
          subtitle: 'الصيانة والتنظيف',
          onTap: () => context.go(AppRoutes.tasks),
        ),
      if (can.can(Permissions.inventoryView))
        SectionTile(
          icon: LucideIcons.package,
          title: 'المخزن',
          subtitle: 'المواد والكميات',
          onTap: () => context.go(AppRoutes.inventory),
        ),
      if (can.can(Permissions.financeView))
        SectionTile(
          icon: LucideIcons.wallet,
          title: 'الحركات المالية',
          subtitle: 'القبض والصرف',
          onTap: () => context.go(AppRoutes.finance),
        ),
    ];

    if (tiles.isEmpty) {
      return NzDashedBox(
        child: Text(
          'لا توجد أقسام متاحة لحسابك. راجع مدير الفندق.',
          textAlign: TextAlign.center,
          style: AppText.body(14, color: AppColors.inkMuted),
        ),
      );
    }

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
                // An odd number of tiles leaves the last row half empty.
                if (i + 1 < tiles.length)
                  Expanded(child: tiles[i + 1])
                else
                  const Spacer(),
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
