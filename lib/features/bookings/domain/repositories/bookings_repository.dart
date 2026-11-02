import '../entities/booking.dart';
import '../entities/new_booking.dart';

/// What the app can do with bookings.
/// The real implementation is in data/repositories/bookings_repository_impl.dart.
abstract class BookingsRepository {
  /// All bookings, newest first. Group bookings come as one row.
  Future<List<Booking>> getBookings();

  /// Holds the rooms for 5 minutes while the form is filled. Returns the lock ids.
  /// If one room can't be held, the others are released and the error is thrown.
  Future<List<int>> holdRooms(List<int> roomIds);

  /// Releases holds that were not used.
  Future<void> releaseHolds(List<int> lockIds);

  /// Confirms the held rooms and records the payment received now.
  Future<void> createBooking(NewBooking booking);

  Future<void> checkIn(Booking booking);
  Future<void> checkOut(Booking booking);
  Future<void> cancel(Booking booking);
}
