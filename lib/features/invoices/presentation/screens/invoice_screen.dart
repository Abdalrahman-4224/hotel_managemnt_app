import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/invoices_local_data_source.dart';
import '../widgets/invoice_paper.dart';

/// Printable guest invoice, with share and print actions.
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoice = const InvoicesLocalDataSource().getInvoice();
    void share() => showNzToast(context, 'جُهّز رابط الفاتورة للمشاركة.');

    return Scaffold(
      backgroundColor: AppColors.paperWarm,
      body: Column(
        children: [
          NzPageHeader(
            showBack: true,
            subtitle: invoice.bookingLine,
            title: 'الفاتورة',
            actions: [
              NzIconButton(
                icon: LucideIcons.share2,
                tooltip: 'مشاركة الفاتورة',
                onPressed: share,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [InvoicePaper(invoice: invoice)],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              30 + MediaQuery.paddingOf(context).bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.paper,
              border: Border(top: BorderSide(color: AppColors.lineStrong)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: NzOutlineButton(
                    label: 'مشاركة',
                    height: 54,
                    onPressed: share,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: NzPrimaryButton(
                    label: 'طباعة',
                    icon: LucideIcons.printer,
                    onPressed: () => _openPrint(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrint(BuildContext context) async {
    var copy = 0;
    const copies = ['نسخة النزيل', 'نسخة الفندق', 'النسختان'];
    final printed = await showNzSheet<bool>(
      context,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NzSheetTitle('طباعة الفاتورة'),
            const SizedBox(height: 14),
            Text(
              'تُطبع بعملتها الأصلية مع سجل الدفعات وتوقيع الموظف.',
              style: AppText.body(13.5, color: AppColors.inkMuted, height: 1.6),
            ),
            const SizedBox(height: 14),
            for (final (i, label) in copies.indexed) ...[
              if (i > 0) const SizedBox(height: 8),
              NzRadioRow(
                label: label,
                selected: copy == i,
                onTap: () => setSheet(() => copy = i),
              ),
            ],
            const SizedBox(height: 14),
            NzPrimaryButton(
              label: 'إرسال إلى الطابعة',
              onPressed: () => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    );
    if (printed == true && context.mounted) {
      showNzToast(context, 'أُرسلت الفاتورة إلى الطابعة.');
    }
  }
}
