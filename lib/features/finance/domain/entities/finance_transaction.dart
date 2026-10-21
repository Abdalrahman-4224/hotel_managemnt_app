enum TxKind { income, expense }

enum TxMethod { cash, card }

enum TxCurrency { usd, iqd }

extension TxMethodLabel on TxMethod {
  String get label => this == TxMethod.cash ? 'نقد' : 'بطاقة';
}

extension TxCurrencyLabel on TxCurrency {
  String get label => this == TxCurrency.usd ? 'دولار' : 'دينار';
}

extension TxKindLabel on TxKind {
  String get label => this == TxKind.income ? 'إيراد' : 'مصروف';
}

/// A money movement. Currencies are never converted – each row is in
/// exactly one currency.
class FinanceTransaction {
  const FinanceTransaction({
    required this.date,
    required this.kind,
    required this.reference,
    required this.method,
    required this.staff,
    required this.amount,
    required this.currency,
  });

  /// `d/m` within the current year, or `اليوم` for today.
  final String date;
  final TxKind kind;
  final String reference;
  final TxMethod method;
  final String staff;
  final String amount;
  final TxCurrency currency;

  bool get isIncome => kind == TxKind.income;

  String get signedAmount => '${isIncome ? '+' : '−'}$amount';

  String get fullDate => date == 'اليوم' ? date : '$date/2026';

  /// The correcting entry: same amount, opposite direction.
  FinanceTransaction reversed() => FinanceTransaction(
    date: 'اليوم',
    kind: isIncome ? TxKind.expense : TxKind.income,
    reference: 'عكس: $reference',
    method: method,
    staff: 'أنت',
    amount: amount,
    currency: currency,
  );
}

class FinanceTotals {
  const FinanceTotals({
    required this.incomeUsd,
    required this.incomeIqd,
    required this.expenseUsd,
    required this.expenseIqd,
    required this.netUsd,
    required this.netIqd,
  });

  final String incomeUsd;
  final String incomeIqd;
  final String expenseUsd;
  final String expenseIqd;
  final String netUsd;
  final String netIqd;
}
