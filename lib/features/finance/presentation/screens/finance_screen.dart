import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/finance_controller.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/transactions_table.dart';
import 'finance_full_table_screen.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final _controller = FinanceController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _expand() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) =>
            FinanceFullTableScreen(controller: _controller),
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
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16, 14, 16, navPad + 76),
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
                            const SizedBox(width: 10),
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
                        const SizedBox(height: 10),
                        NzCard(
                          color: AppColors.ink,
                          borderColor: null,
                          radius: 18,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                              const SizedBox(width: 12),
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
                        const SizedBox(height: 14),
                        FinanceToolbar(
                          controller: c,
                          onFilter: () => showFinanceFilter(context, c),
                        ),
                        if (c.activeFilters.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _ActiveChips(controller: c),
                        ],
                        const SizedBox(height: 14),
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
                              height: 40,
                              radius: 12,
                              fontSize: 13,
                              onPressed: _expand,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TransactionsTable(
                          groups: c.groups,
                          onOpen: (t) => showTransactionDetail(context, c, t),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.info,
                              size: 13,
                              color: AppColors.inkFaint,
                            ),
                            const SizedBox(width: 6),
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
                ],
              ),
              PositionedDirectional(
                end: 16,
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
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: AppText.body(12.5, color: AppColors.inkMuted)),
            ],
          ),
          const SizedBox(height: 6),
          NzAmount(usd, 'دولار', size: 20),
          const SizedBox(height: 6),
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
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final a in controller.activeFilters)
          Semantics(
            button: true,
            label: 'إزالة فلتر ${a.label}',
            child: GestureDetector(
              onTap: a.clear,
              child: Container(
                height: 34,
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                decoration: BoxDecoration(
                  color: AppColors.goldTint,
                  borderRadius: BorderRadius.circular(99),
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
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.x,
                      size: 13,
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
