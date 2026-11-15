import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../controllers/finance_controller.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/transactions_table.dart';
import 'finance_full_table_screen.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  late final _controller = FinanceController(
    repository: ref.read(financeRepositoryProvider),
  )..load();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    final canReverse = ref.read(canProvider).can(Permissions.financeCreate);
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => FinanceFullTableScreen(
          controller: _controller,
          canReverse: canReverse,
        ),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navPad = NzBottomNav.bodyPadding(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final c = _controller;
        final totals = c.totals;
        return Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  NzPageHeader(
                    subtitle: c.periodLine,
                    title: 'الحركات المالية',
                    actions: [
                      NzIconButton(
                        icon: LucideIcons.download,
                        tooltip: 'تصدير',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Expanded(
                    child: NzAsyncBody(
                      // Rows stay on screen after the first load, even if a reload fails.
                      hasValue:
                          !c.isLoading &&
                          (c.error == null || c.rows.isNotEmpty),
                      error: c.error,
                      onRetry: c.load,
                      child: () => RefreshIndicator(
                        onRefresh: c.load,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.s16,
                            AppSpacing.s14,
                            AppSpacing.s16,
                            navPad + 76.r,
                          ),
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _TotalCard(
                                    icon: LucideIcons.trendingUp,
                                    iconColor: AppColors.goldDeep,
                                    label: 'الإيرادات',
                                    usd: totals.incomeUsd,
                                    iqd: totals.incomeIqd,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.s10),
                                Expanded(
                                  child: _TotalCard(
                                    icon: LucideIcons.trendingDown,
                                    iconColor: AppColors.inkMuted,
                                    label: 'المصروفات',
                                    usd: totals.expenseUsd,
                                    iqd: totals.expenseIqd,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.s10),
                            NzCard(
                              color: AppColors.ink,
                              borderColor: null,
                              radius: AppRadius.r18,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16,
                                vertical: AppSpacing.s14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'الصافي',
                                      style: AppText.body(
                                        13,
                                        color: AppColors.onInkMuted,
                                      ),
                                    ),
                                  ),
                                  NzAmount(
                                    totals.netUsd,
                                    'دولار',
                                    size: 22,
                                    color: AppColors.onInk,
                                    unitColor: AppColors.onInkMuted,
                                  ),
                                  SizedBox(width: AppSpacing.s12),
                                  NzAmount(
                                    totals.netIqd,
                                    'دينار',
                                    size: 16,
                                    color: AppColors.goldLight,
                                    unitColor: AppColors.onInkMuted,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.s14),
                            FinanceToolbar(
                              controller: c,
                              onFilter: () => showFinanceFilter(context, c),
                            ),
                            if (c.activeFilters.isNotEmpty) ...[
                              SizedBox(height: AppSpacing.s10),
                              _ActiveChips(controller: c),
                            ],
                            SizedBox(height: AppSpacing.s14),
                            Row(
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(text: 'الحركات '),
                                        TextSpan(
                                          text: '${c.rows.length}',
                                          style: AppText.num(
                                            12.5,
                                            weight: FontWeight.w500,
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: AppText.display(16, height: 1.4),
                                  ),
                                ),
                                NzOutlineButton(
                                  label: 'تكبير',
                                  icon: LucideIcons.maximize2,
                                  height: 40.r,
                                  radius: AppRadius.r12,
                                  fontSize: 13,
                                  onPressed: _expand,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.s10),
                            TransactionsTable(
                              groups: c.groups,
                              onOpen: (t) => showTransactionDetail(
                                context,
                                c,
                                t,
                                canReverse: ref
                                    .watch(canProvider)
                                    .can(Permissions.financeCreate),
                              ),
                            ),
                            SizedBox(height: AppSpacing.s14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.info,
                                  size: 13.r,
                                  color: AppColors.inkFaint,
                                ),
                                SizedBox(width: AppSpacing.s6),
                                Text(
                                  'لا سعر صرف — كل عملة تُحسب على حدة.',
                                  style: AppText.body(
                                    12,
                                    color: AppColors.inkFaint,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (ref.watch(canProvider).can(Permissions.financeCreate))
                PositionedDirectional(
                  end: AppSpacing.s16,
                  bottom: NzBottomNav.fabBottom(context),
                  child: NzFloatingButton(
                    label: 'حركة جديدة',
                    onPressed: () => showNewTransaction(context, c),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.usd,
    required this.iqd,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String usd;
  final String iqd;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: AppRadius.r18,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15.r, color: iconColor),
              SizedBox(width: AppSpacing.s6),
              Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
            ],
          ),
          SizedBox(height: AppSpacing.s6),
          NzAmount(usd, 'دولار', size: 20),
          SizedBox(height: AppSpacing.s6),
          NzAmount(iqd, 'دينار', size: 14, color: AppColors.goldDeep),
        ],
      ),
    );
  }
}

class _ActiveChips extends StatelessWidget {
  const _ActiveChips({required this.controller});

  final FinanceController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s6,
      runSpacing: AppSpacing.s6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final a in controller.activeFilters)
          Semantics(
            button: true,
            label: 'إزالة فلتر ${a.label}',
            child: GestureDetector(
              onTap: a.clear,
              child: Container(
                height: 34.r,
                padding: EdgeInsetsDirectional.only(
                  start: AppSpacing.s12,
                  end: AppSpacing.s8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: const Color(0x73B68235)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      a.label,
                      style: AppText.body(
                        13,
                        weight: FontWeight.w600,
                        color: AppColors.goldDarkest,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s6),
                    Icon(
                      LucideIcons.x,
                      size: 13.r,
                      color: AppColors.goldDarkest,
                    ),
                  ],
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: controller.clearFilters,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s6,
              vertical: AppSpacing.s8,
            ),
            child: Text(
              'مسح الكل',
              style: AppText.body(
                13,
                weight: FontWeight.w500,
                color: AppColors.inkMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
