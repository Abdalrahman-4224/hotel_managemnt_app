import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/finance_transaction.dart';
import '../controllers/finance_controller.dart';

/// Detail sheet for a transaction. Rows are never deleted – the only
/// action is a reversing entry.
Future<void> showTransactionDetail(
  BuildContext context,
  FinanceController controller,
  FinanceTransaction tx,
) {
  return showNzSheet<void>(
    context,
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NzSheetTitle(
          tx.reference,
          trailing: NzTag(
            tx.kind.label,
            height: 24,
            fontSize: 11.5,
            tone: tx.isIncome ? NzTagTone.gold : NzTagTone.neutral,
          ),
        ),
        const SizedBox(height: 14),
        NzCard(
          radius: 18,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(
                tx.signedAmount,
                textDirection: TextDirection.ltr,
                style: AppText.num(30, height: 1.2),
              ),
              Text(
                tx.currency.label,
                style: AppText.body(13, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final (i, f) in [
              ('التاريخ', tx.fullDate),
              ('الطريقة', tx.method.label),
              ('الموظف', tx.staff),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _Fact(label: f.$1, value: f.$2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'الحركة لا تُحذف — التصحيح يكون بحركة معاكسة.',
          style: AppText.body(12.5, color: AppColors.inkFaint, height: 1.6),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: NzOutlineButton(
                label: 'إغلاق',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: NzPrimaryButton(
                label: 'حركة معاكسة',
                height: 52,
                fontSize: 15,
                onPressed: () {
                  controller.reverse(tx);
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(13.5, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Filter sheet: period, currency and payment method.
Future<void> showFinanceFilter(
  BuildContext context,
  FinanceController controller,
) {
  var draft = controller.filter;
  return showNzSheet<void>(
    context,
    gap: 16,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        Widget group<T>(
          String label,
          List<(T, String)> opts,
          T current,
          void Function(T) pick,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
              const SizedBox(height: 7),
              Row(
                children: [
                  for (final (i, o) in opts.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: NzChoicePill(
                        label: o.$2,
                        selected: o.$1 == current,
                        height: 44,
                        radius: 12,
                        fontSize: 14,
                        horizontalPadding: 6,
                        offColor: AppColors.ink,
                        onTap: () => setSheet(() => pick(o.$1)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NzSheetTitle(
              'فلترة الحركات',
              trailing: NzLinkButton(
                label: 'إعادة ضبط',
                weight: FontWeight.w600,
                underline: false,
                onPressed: () => setSheet(() => draft = const FinanceFilter()),
              ),
            ),
            const SizedBox(height: 16),
            group<Period>(
              'الفترة',
              [for (final p in Period.values) (p, p.short)],
              draft.period,
              (v) => draft = draft.copyWith(period: v),
            ),
            const SizedBox(height: 16),
            group<TxCurrency?>(
              'العملة',
              const [
                (null, 'الكل'),
                (TxCurrency.iqd, 'دينار'),
                (TxCurrency.usd, 'دولار'),
              ],
              draft.currency,
              (v) => draft = draft.copyWith(currency: () => v),
            ),
            const SizedBox(height: 16),
            group<TxMethod?>(
              'طريقة الدفع',
              const [
                (null, 'الكل'),
                (TxMethod.cash, 'نقد'),
                (TxMethod.card, 'بطاقة'),
              ],
              draft.method,
              (v) => draft = draft.copyWith(method: () => v),
            ),
            const SizedBox(height: 16),
            NzPrimaryButton(
              label: 'عرض ${controller.countForDraft(draft)} حركة',
              onPressed: () {
                controller.applyFilter(draft);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    ),
  );
}

/// Form to record a new income/expense.
Future<void> showNewTransaction(
  BuildContext context,
  FinanceController controller,
) {
  var kind = TxKind.income;
  var currency = TxCurrency.iqd;
  var method = TxMethod.cash;
  var error = false;
  final amount = TextEditingController();
  final reference = TextEditingController();

  return showNzSheet<void>(
    context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) {
        Widget seg<T>(
          String label,
          List<NzSegment<T>> segs,
          T value,
          void Function(T) pick,
        ) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: AppText.body(13, color: AppColors.inkMuted)),
              const SizedBox(height: 6),
              NzSegmented<T>(
                segments: segs,
                selected: value,
                onChanged: (v) => setSheet(() => pick(v)),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NzSheetTitle('حركة مالية جديدة'),
            const SizedBox(height: 14),
            seg<TxKind>(
              'نوع الحركة',
              const [
                NzSegment(TxKind.income, 'قبض'),
                NzSegment(TxKind.expense, 'صرف'),
              ],
              kind,
              (v) => kind = v,
            ),
            const SizedBox(height: 14),
            seg<TxCurrency>(
              'العملة',
              const [
                NzSegment(TxCurrency.iqd, 'دينار'),
                NzSegment(TxCurrency.usd, 'دولار'),
              ],
              currency,
              (v) => currency = v,
            ),
            const SizedBox(height: 14),
            seg<TxMethod>(
              'الطريقة',
              const [
                NzSegment(TxMethod.cash, 'نقد'),
                NzSegment(TxMethod.card, 'بطاقة'),
              ],
              method,
              (v) => method = v,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NzTextField(
                    label: 'المبلغ (${currency.label})',
                    hint: '250',
                    controller: amount,
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
                    ],
                    style: AppText.num(17),
                    onChanged: (_) => setSheet(() => error = false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NzTextField(
                    label: 'المرجع',
                    hint: 'حجز #1042',
                    controller: reference,
                    onChanged: (_) => setSheet(() => error = false),
                  ),
                ),
              ],
            ),
            if (error) ...[
              const SizedBox(height: 8),
              Text(
                'اكتب المبلغ والمرجع.',
                style: AppText.body(13, color: AppColors.goldDeep),
              ),
            ],
            const SizedBox(height: 14),
            NzPrimaryButton(
              label: 'تسجيل الحركة',
              onPressed: () {
                if (amount.text.isEmpty || reference.text.trim().isEmpty) {
                  setSheet(() => error = true);
                  return;
                }
                controller.add(
                  FinanceTransaction(
                    date: 'اليوم',
                    kind: kind,
                    reference: reference.text.trim(),
                    method: method,
                    staff: 'أنت',
                    amount: amount.text,
                    currency: currency,
                  ),
                );
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    ),
  );
}
