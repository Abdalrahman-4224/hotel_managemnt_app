import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class BookingsDataSource {
  final ApiClient apiClient;

  BookingsDataSource(this.apiClient);

  /// One row per booking, with guest, rooms and dates.
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    final data = await apiClient.get('/bookings');
    return List<Map<String, dynamic>>.from(data);
  }

  /// A booking with its `details` (rooms, guests, nights, price).
  Future<Map<String, dynamic>> fetchBooking(int bookingId) async {
    final data = await apiClient.get('/bookings/$bookingId');
    return data;
  }

  /// Holds a room for 5 minutes. Returns the lock.
  Future<Map<String, dynamic>> holdRoom(int roomId) async {
    final data = await apiClient.post(
      '/bookings/holdRoom',
      data: {'room_id': roomId},
    );
    return data;
  }

  /// Lets go of a hold early (the user closed the form).
  Future<void> releaseHold(int lockId) async {
    await apiClient.put('/room-locks/$lockId', data: {'is_active': false});
  }

  /// Creates the booking, guest and booking detail for a held room.
  Future<Map<String, dynamic>> confirmBooking(Map<String, dynamic> body) async {
    final data = await apiClient.post('/bookings/confirmBooking', data: body);
    return data;
  }

  Future<Map<String, dynamic>> createCampaign(Map<String, dynamic> body) async {
    final data = await apiClient.post('/campaigns/createCampaign', data: body);
    return data;
  }

  /// Body is `{booking_id}` for one booking or `{campaign_id}` for a group.
  Future<void> checkIn(Map<String, dynamic> body) async {
    await apiClient.post('/bookings/checkIn', data: body);
  }

  Future<void> checkOut(Map<String, dynamic> body) async {
    await apiClient.post('/bookings/checkOut', data: body);
  }

  Future<void> cancel(int bookingId) async {
    await apiClient.post('/bookings/cancel', data: {'booking_id': bookingId});
  }

  /// Records a payment against a booking.
  Future<void> addPayment(Map<String, dynamic> body) async {
    await apiClient.post('/transactions', data: body);
  }
}

final bookingsDataSourceProvider = Provider<BookingsDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingsDataSource(apiClient);
});
