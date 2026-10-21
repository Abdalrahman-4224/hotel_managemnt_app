import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../controllers/finance_controller.dart';
import '../widgets/finance_sheets.dart';
import '../widgets/transactions_table.dart';

/// "كل الحركات" – the transactions table expanded to full screen.
class FinanceFullTableScreen extends StatelessWidget {
  const FinanceFullTableScreen({super.key, required this.controller});

  final FinanceController controller;

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
                  iconSize: 18,
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
                  16,
                  14,
                  16,
                  30 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  TransactionsTable(
                    groups: controller.groups,
                    onOpen: (t) =>
                        showTransactionDetail(context, controller, t),
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
