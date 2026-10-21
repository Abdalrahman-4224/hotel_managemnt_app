class InvoiceLine {
  const InvoiceLine(this.description, this.quantity, {this.usd, this.iqd});

  final String description;
  final int quantity;
  final String? usd;
  final String? iqd;
}

class InvoicePayment {
  const InvoicePayment(this.description, this.amount);

  final String description;
  final String amount;
}

class Invoice {
  const Invoice({
    required this.number,
    required this.bookingLine,
    required this.issuedOn,
    required this.hotelName,
    required this.hotelAddress,
    required this.guest,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.lines,
    required this.totalUsd,
    required this.totalIqd,
    required this.payments,
    required this.paidInFull,
    required this.staff,
  });

  final String number;

  /// Subtitle in the header, e.g. "حجز #1039 · ليلى العتيبي".
  final String bookingLine;
  final String issuedOn;
  final String hotelName;
  final String hotelAddress;
  final String guest;
  final String room;
  final String checkIn;
  final String checkOut;
  final List<InvoiceLine> lines;
  final String totalUsd;
  final String totalIqd;
  final List<InvoicePayment> payments;
  final bool paidInFull;
  final String staff;
}
