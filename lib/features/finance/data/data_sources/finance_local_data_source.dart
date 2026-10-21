import '../../domain/entities/finance_transaction.dart';

/// Sample data from the design. Replace with an API data source.
class FinanceLocalDataSource {
  const FinanceLocalDataSource();

  FinanceTotals getTotals() => const FinanceTotals(
    incomeUsd: '41,280',
    incomeIqd: '53,600,000',
    expenseUsd: '9,140',
    expenseIqd: '12,300,000',
    netUsd: '32,140',
    netIqd: '41,300,000',
  );

  List<FinanceTransaction> getTransactions() => const [
    FinanceTransaction(
      date: '19/8',
      kind: TxKind.income,
      reference: 'حجز #1042',
      method: TxMethod.cash,
      staff: 'سارة العبدلي',
      amount: '720',
      currency: TxCurrency.usd,
    ),
    FinanceTransaction(
      date: '19/8',
      kind: TxKind.expense,
      reference: 'مواد تنظيف',
      method: TxMethod.card,
      staff: 'أحمد الجابري',
      amount: '310',
      currency: TxCurrency.usd,
    ),
    FinanceTransaction(
      date: '18/8',
      kind: TxKind.income,
      reference: 'حملة #12',
      method: TxMethod.cash,
      staff: 'سارة العبدلي',
      amount: '6,288,000',
      currency: TxCurrency.iqd,
    ),
    FinanceTransaction(
      date: '18/8',
      kind: TxKind.income,
      reference: 'حجز #1039',
      method: TxMethod.card,
      staff: 'يوسف الحلبي',
      amount: '450',
      currency: TxCurrency.usd,
    ),
    FinanceTransaction(
      date: '17/8',
      kind: TxKind.expense,
      reference: 'رواتب الموظفين',
      method: TxMethod.cash,
      staff: 'الإدارة',
      amount: '2,400,000',
      currency: TxCurrency.iqd,
    ),
    FinanceTransaction(
      date: '28/7',
      kind: TxKind.income,
      reference: 'حملة #9',
      method: TxMethod.cash,
      staff: 'سارة العبدلي',
      amount: '4,150,000',
      currency: TxCurrency.iqd,
    ),
  ];
}
