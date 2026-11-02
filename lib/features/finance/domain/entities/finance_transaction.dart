import '../../../../core/utils/formatters.dart';

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
    required this.id,
    required this.when,
    required this.kind,
    required this.reference,
    required this.method,
    required this.staff,
    required this.value,
    required this.currency,
    this.bookingId,
  });

  final int id;
  final DateTime when;
  final TxKind kind;
  final String reference;
  final TxMethod method;
  final String staff;
  final double value;
  final TxCurrency currency;
  final int? bookingId;

  bool get isIncome => kind == TxKind.income;

  String get amount => fmtNum(value.abs());

  String get signedAmount => '${isIncome ? '+' : '−'}$amount';

  bool get isToday {
    final now = DateTime.now();
    return when.year == now.year &&
        when.month == now.month &&
        when.day == now.day;
  }

  /// `اليوم` for today, otherwise `d/m/yyyy`.
  String get fullDate =>
      isToday ? 'اليوم' : '${when.day}/${when.month}/${when.year}';
}

/// What the new-transaction form collects (also used for a reversing entry).
class NewTransaction {
  const NewTransaction({
    required this.kind,
    required this.reference,
    required this.method,
    required this.amount,
    required this.currency,
    this.bookingId,
  });

  final TxKind kind;
  final String reference;
  final TxMethod method;
  final double amount;
  final TxCurrency currency;
  final int? bookingId;
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
