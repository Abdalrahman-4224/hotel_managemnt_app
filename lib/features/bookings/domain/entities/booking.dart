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
    BookingStatus.cancelled => 'عرض',
  };

  /// Status after the main action, if it changes.
  BookingStatus? get next => switch (this) {
    BookingStatus.confirmed || BookingStatus.upcoming => BookingStatus.staying,
    BookingStatus.staying => BookingStatus.departed,
    _ => null,
  };

  bool get isUpcoming =>
      this == BookingStatus.upcoming || this == BookingStatus.confirmed;
}

class Booking {
  const Booking({
    required this.id,
    required this.guest,
    required this.rooms,
    required this.isGroup,
    required this.status,
    required this.isToday,
    required this.checkIn,
    required this.checkOut,
    required this.usd,
    required this.iqd,
  });

  final String id;
  final String guest;
  final String rooms;
  final bool isGroup;
  final BookingStatus status;
  final bool isToday;
  final String checkIn;
  final String checkOut;
  final String usd;
  final String iqd;

  String get kind => isGroup ? 'حملة' : 'فرد';

  bool get _hasUsd => usd != '—' && usd != '0';
  String get amount => _hasUsd ? usd : iqd;
  String get currency => _hasUsd ? 'دولار' : (iqd == '0' ? '—' : 'دينار');
}
