import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../rooms/presentation/controllers/floors_controller.dart';
import '../../data/repositories/bookings_repository_impl.dart';
import '../../domain/entities/booking.dart';

/// Loads the bookings list. Actions call the server, then reload.
///
///   ref.watch(bookingsControllerProvider).when(...)
class BookingsController extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() {
    return ref.read(bookingsRepositoryProvider).getBookings();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(bookingsRepositoryProvider).getBookings(),
    );
  }

  /// Errors are rethrown so the screen can show them.
  Future<void> checkIn(Booking booking) async {
    await ref.read(bookingsRepositoryProvider).checkIn(booking);
    await _reload();
  }

  Future<void> checkOut(Booking booking) async {
    await ref.read(bookingsRepositoryProvider).checkOut(booking);
    await _reload();
  }

  Future<void> cancel(Booking booking) async {
    await ref.read(bookingsRepositoryProvider).cancel(booking);
    await _reload();
  }

  /// These actions change room statuses too, so the room map and home reload as well.
  Future<void> _reload() async {
    ref.invalidate(floorsControllerProvider);
    ref.invalidate(dashboardProvider);
    await refresh();
  }
}

final bookingsControllerProvider =
    AsyncNotifierProvider<BookingsController, List<Booking>>(
      BookingsController.new,
    );
