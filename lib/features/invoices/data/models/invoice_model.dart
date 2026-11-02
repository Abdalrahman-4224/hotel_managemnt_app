import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/invoice.dart';

/// Builds an invoice from GET /bookings/:id and the booking's transactions.
class InvoiceModel {
  const InvoiceModel._();

  static Invoice fromJson({
    required Map<String, dynamic> booking,
    required List<Map<String, dynamic>> transactions,
    required String hotelName,
    required String staff,
  }) {
    final id = parseInt(booking['booking_id'])!;
    final details = List<Map<String, dynamic>>.from(booking['details'] ?? []);
    final first = details.isEmpty ? const <String, dynamic>{} : details.first;
    final guest = (first['guest_name'] ?? '—').toString();

    // One line per room: nights × price per night (in dollars).
    final lines = [
      for (final d in details)
        InvoiceLine(
          '${d['night_count']} ليالٍ × ${fmtNum(parseDouble(d['price_per_night']) ?? 0)} · غرفة ${d['room_number']}',
          parseInt(d['night_count']) ?? 0,
          usd: fmtNum(
            (parseInt(d['night_count']) ?? 0) *
                (parseDouble(d['price_per_night']) ?? 0),
          ),
        ),
    ];

    // Money received for this booking.
    var paidUsd = 0.0;
    var paidIqd = 0.0;
    final payments = <InvoicePayment>[];
    for (final t in transactions) {
      if (parseInt(t['booking_id']) != id ||
          t['transaction_type'] != 'Revenue') {
        continue;
      }
      final amount = parseDouble(t['amount']) ?? 0;
      final isIqd = t['currency'] == 'IQD';
      if (isIqd) {
        paidIqd += amount;
      } else {
        paidUsd += amount;
      }
      final when = parseDate(t['transaction_date']);
      final method = t['payment_method'] == 'CreditCard' ? 'بطاقة' : 'نقداً';
      payments.add(
        InvoicePayment(
          '$method · ${when?.day}/${when?.month}',
          isIqd ? '${fmtNum(amount)} د.ع' : '${fmtNum(amount)} \$',
        ),
      );
    }

    final total = parseDouble(booking['total_amount']) ?? 0;
    return Invoice(
      number: '$id',
      bookingLine: 'حجز #$id · $guest',
      issuedOn: apiDate(DateTime.now()),
      hotelName: hotelName,
      hotelAddress: '',
      guest: guest,
      room: [for (final d in details) d['room_number']].join('، '),
      checkIn: fmtDate(parseDate(first['check_in_date'])),
      checkOut: fmtDate(parseDate(first['check_out_date'])),
      lines: lines,
      totalUsd: fmtNum(total),
      totalIqd: paidIqd > 0 ? fmtNum(paidIqd) : '—',
      payments: payments,
      paidInFull: paidUsd >= total,
      staff: staff,
    );
  }
}
