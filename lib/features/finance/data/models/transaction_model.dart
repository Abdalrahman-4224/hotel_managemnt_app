import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/finance_transaction.dart';

/// Converts money movements between the app and /transactions.
class TransactionModel {
  const TransactionModel._();

  static FinanceTransaction fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      id: parseInt(json['transaction_id'])!,
      when: parseDate(json['transaction_date']) ?? DateTime.now(),
      kind: json['transaction_type'] == 'Expense'
          ? TxKind.expense
          : TxKind.income,
      reference: json['description'] ?? json['category'] ?? '',
      method: json['payment_method'] == 'CreditCard'
          ? TxMethod.card
          : TxMethod.cash,
      staff: json['staff_name'] ?? '—',
      value: parseDouble(json['amount']) ?? 0,
      currency: json['currency'] == 'IQD' ? TxCurrency.iqd : TxCurrency.usd,
      bookingId: parseInt(json['booking_id']),
    );
  }

  static Map<String, dynamic> newToJson(NewTransaction tx) {
    return {
      'transaction_type': tx.kind == TxKind.income ? 'Revenue' : 'Expense',
      'category': tx.bookingId != null ? 'Booking' : 'General',
      'description': tx.reference,
      'amount': tx.amount,
      'currency': tx.currency == TxCurrency.iqd ? 'IQD' : 'USD',
      'payment_method': tx.method == TxMethod.card ? 'CreditCard' : 'Cash',
      'booking_id': tx.bookingId,
    };
  }
}
