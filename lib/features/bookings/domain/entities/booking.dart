enum BookingStatus { confirmed, upcoming, staying, departed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
    BookingStatus.confirmed => 'مؤكد',
    BookingStatus.upcoming => 'قادم',
    BookingStatus.staying => 'مقيم',
    BookingStatus.departed => 'مغادر',
    BookingStatus.cancelled => 'ملغى',
  };

  /// Label of the main action in the booking sheet.
  String get action => switch (this) {
    BookingStatus.confirmed || BookingStatus.upcoming => 'تسجيل دخول',
    BookingStatus.staying => 'تسوية ومغادرة',
    BookingStatus.departed => 'الفاتورة',
    BookingStatus.cancelled => 'إغلاق',
  };

  bool get isUpcoming =>
      this == BookingStatus.upcoming || this == BookingStatus.confirmed;
}

/// A booking as the list shows it. A group (campaign) booking is one
/// server booking per room; they are shown together as one row.
class Booking {
  const Booking({
    required this.id,
    required this.bookingIds,
    required this.campaignId,
    required this.guest,
    required this.rooms,
    required this.status,
    required this.checkIn,
    required this.checkOut,
    required this.total,
    required this.paid,
  });

  /// The booking number shown on screen (the first one for a group).
  final int id;

  /// Every server booking in this row (one for an individual booking).
  final List<int> bookingIds;
  final int? campaignId;
  final String guest;
  final String rooms;
  final BookingStatus status;
  final DateTime? checkIn;
  final DateTime? checkOut;

  /// Booking amounts are in US dollars.
  final double total;
  final double paid;

  bool get isGroup => campaignId != null;

  String get kind => isGroup ? 'حملة' : 'فرد';

  bool get isToday {
    final now = DateTime.now();
    bool same(DateTime? d) =>
        d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;
    return same(checkIn) || same(checkOut);
  }
}
