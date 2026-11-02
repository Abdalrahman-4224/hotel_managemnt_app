import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/booking.dart';

/// A row from GET /bookings.
class BookingModel {
  final int id;
  final int? campaignId;
  final String? campaignName;
  final String? guestName;
  final String? roomNumbers;
  final String bookingStatus;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final double total;
  final double paid;

  const BookingModel({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.guestName,
    required this.roomNumbers,
    required this.bookingStatus,
    required this.checkIn,
    required this.checkOut,
    required this.total,
    required this.paid,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: parseInt(json['booking_id'])!,
      campaignId: parseInt(json['campaign_id']),
      campaignName: json['name_campaign'],
      guestName: json['guest_name'],
      roomNumbers: json['room_numbers'],
      bookingStatus: json['booking_status'] ?? 'Confirmed',
      checkIn: parseDate(json['check_in_date']),
      checkOut: parseDate(json['check_out_date']),
      total: parseDouble(json['total_amount']) ?? 0,
      paid: parseDouble(json['paid_amount']) ?? 0,
    );
  }

  /// Server status → app status. A confirmed booking that starts after today is "upcoming".
  BookingStatus get status {
    switch (bookingStatus) {
      case 'CheckedIn':
        return BookingStatus.staying;
      case 'CheckedOut':
        return BookingStatus.departed;
      case 'Cancelled':
        return BookingStatus.cancelled;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (checkIn != null && checkIn!.isAfter(today)) {
      return BookingStatus.upcoming;
    }
    return BookingStatus.confirmed;
  }

  Booking toEntity() {
    return Booking(
      id: id,
      bookingIds: [id],
      campaignId: campaignId,
      guest: guestName ?? '—',
      rooms: roomNumbers ?? '—',
      status: status,
      checkIn: checkIn,
      checkOut: checkOut,
      total: total,
      paid: paid,
    );
  }

  /// One row for all the bookings of a campaign (one booking per room).
  static Booking groupToEntity(List<BookingModel> models) {
    final first = models.first;
    final rooms = [
      for (final m in models)
        if (m.roomNumbers != null) m.roomNumbers!,
    ];
    return Booking(
      id: first.id,
      bookingIds: [for (final m in models) m.id],
      campaignId: first.campaignId,
      guest: first.campaignName ?? first.guestName ?? '—',
      rooms: rooms.length > 3 ? '${rooms.length} غرف' : rooms.join(', '),
      status: first.status,
      checkIn: first.checkIn,
      checkOut: first.checkOut,
      total: models.fold(0, (sum, m) => sum + m.total),
      paid: models.fold(0, (sum, m) => sum + m.paid),
    );
  }
}
