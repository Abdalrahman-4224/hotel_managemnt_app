import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/finance_controller.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/transactions_table.dart';

/// "كل الحركات" – the transactions table expanded to full screen.
class FinanceFullTableScreen extends StatelessWidget {
  const FinanceFullTableScreen({
    super.key,
    required this.controller,
    required this.canReverse,
  });

  final FinanceController controller;

  /// Whether this user may record the reversing entry (FINANCE_CREATE).
  final bool canReverse;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        body: Column(
          children: [
            NzPageHeader(
              showBack: true,
              subtitle:
                  '${controller.periodLine} · ${controller.rows.length} حركة',
              title: 'كل الحركات',
              actions: [
                NzIconButton(
                  icon: LucideIcons.minimize2,
                  tooltip: 'تصغير الجدول',
                  iconSize: 18.r,
                  iconColor: AppColors.goldDeep,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              bottom: FinanceToolbar(
                controller: controller,
                onFilter: () => showFinanceFilter(context, controller),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s14,
                  AppSpacing.s16,
                  30.r + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  TransactionsTable(
                    groups: controller.groups,
                    onOpen: (t) => showTransactionDetail(
                      context,
                      controller,
                      t,
                      canReverse: canReverse,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
