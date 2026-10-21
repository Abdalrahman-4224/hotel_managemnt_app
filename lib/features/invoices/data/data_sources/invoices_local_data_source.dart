import '../../domain/entities/invoice.dart';

/// Sample data from the design. Replace with an API data source.
class InvoicesLocalDataSource {
  const InvoicesLocalDataSource();

  Invoice getInvoice() => const Invoice(
    number: '1039',
    bookingLine: 'حجز #1039 · ليلى العتيبي',
    issuedOn: '2026-08-19',
    hotelName: 'فندقي · فندق أ',
    hotelAddress: 'بغداد — شارع الرشيد',
    guest: 'ليلى العتيبي',
    room: '305',
    checkIn: '15/8/2026',
    checkOut: '19/8/2026',
    lines: [
      InvoiceLine('3 ليالٍ × 240', 3, usd: '720'),
      InvoiceLine('إفطار', 3, usd: '120'),
      InvoiceLine('خدمة الغرف', 1, iqd: '45,000'),
    ],
    totalUsd: '840',
    totalIqd: '45,000',
    payments: [
      InvoicePayment('عربون نقداً · 15/8', '420 \$'),
      InvoicePayment('تسوية بطاقة · 19/8', '420 \$'),
      InvoicePayment('نقداً · 19/8', '45,000 د.ع'),
    ],
    paidInFull: true,
    staff: 'يوسف الحلبي',
  );
}
