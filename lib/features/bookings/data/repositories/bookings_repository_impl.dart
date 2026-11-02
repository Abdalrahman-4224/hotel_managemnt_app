import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/new_booking.dart';
import '../../domain/repositories/bookings_repository.dart';
import '../data_sources/bookings_data_source.dart';
import '../models/booking_model.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsDataSource dataSource;

  BookingsRepositoryImpl(this.dataSource);

  @override
  Future<List<Booking>> getBookings() async {
    final rows = await dataSource.fetchBookings();
    final models = rows.map(BookingModel.fromJson).toList();

    // Individual bookings are one row each; a campaign's bookings become one row.
    final bookings = <Booking>[];
    final groups = <int, List<BookingModel>>{};
    for (final model in models) {
      if (model.campaignId == null) {
        bookings.add(model.toEntity());
      } else {
        groups.putIfAbsent(model.campaignId!, () => []).add(model);
      }
    }
    for (final group in groups.values) {
      bookings.add(BookingModel.groupToEntity(group));
    }

    bookings.sort((a, b) => b.id.compareTo(a.id));
    return bookings;
  }

  @override
  Future<List<int>> holdRooms(List<int> roomIds) async {
    final lockIds = <int>[];
    try {
      for (final roomId in roomIds) {
        final lock = await dataSource.holdRoom(roomId);
        lockIds.add(parseInt(lock['lock_id'])!);
      }
    } catch (_) {
      // One room is taken: don't keep the others held.
      await releaseHolds(lockIds);
      rethrow;
    }
    return lockIds;
  }

  @override
  Future<void> releaseHolds(List<int> lockIds) async {
    for (final lockId in lockIds) {
      try {
        await dataSource.releaseHold(lockId);
      } catch (_) {
        // The hold ends by itself after 5 minutes anyway.
      }
    }
  }

  @override
  Future<void> createBooking(NewBooking booking) async {
    // A group booking belongs to a campaign, created first.
    int? campaignId;
    if (booking.isGroup) {
      final campaign = await dataSource.createCampaign({
        'name_campaign': booking.groupName,
        'expected_guests_count': booking.heads,
        'total_calculated_cost': booking.total,
      });
      campaignId = parseInt(campaign['campaign_id']);
    }

    // The server keeps one booking per room, so split the total between the rooms.
    final nights = booking.checkOut.difference(booking.checkIn).inDays;
    final roomTotal = booking.total / booking.rooms.length;
    int? firstBookingId;

    for (final room in booking.rooms) {
      final created = await dataSource.confirmBooking({
        'room_id': room.id,
        'check_in_date': apiDate(booking.checkIn),
        'check_out_date': apiDate(booking.checkOut),
        'price_per_night': (roomTotal / nights).toStringAsFixed(2),
        'total_amount': roomTotal.toStringAsFixed(2),
        'meal_plan': booking.withBreakfast
            ? 'WithBreakfast'
            : 'WithoutBreakfast',
        'booking_type': booking.isGroup ? 'Campaign' : 'Individual',
        'campaign_id': campaignId,
        'guest_details': {
          'full_name': booking.guestName,
          'phone': booking.phone,
          'national_id_or_passport': booking.nationalId,
        },
      });
      firstBookingId ??= parseInt(created['booking_id']);
    }

    // Money taken at the desk is recorded as revenue on the (first) booking.
    if (booking.receivedNow > 0) {
      await dataSource.addPayment({
        'booking_id': firstBookingId,
        'transaction_type': 'Revenue',
        'category': 'Booking',
        'amount': booking.receivedNow,
        'currency': 'USD',
        'payment_method': booking.payByCard ? 'CreditCard' : 'Cash',
        'description': 'دفعة حجز #$firstBookingId',
      });
    }
  }

  /// A group is checked in / out with its campaign id, a single booking with its own id.
  Map<String, dynamic> _target(Booking booking) {
    return booking.isGroup
        ? {'campaign_id': booking.campaignId}
        : {'booking_id': booking.id};
  }

  @override
  Future<void> checkIn(Booking booking) {
    return dataSource.checkIn(_target(booking));
  }

  @override
  Future<void> checkOut(Booking booking) {
    return dataSource.checkOut(_target(booking));
  }

  @override
  Future<void> cancel(Booking booking) async {
    for (final bookingId in booking.bookingIds) {
      await dataSource.cancel(bookingId);
    }
  }
}

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  return BookingsRepositoryImpl(ref.watch(bookingsDataSourceProvider));
});
