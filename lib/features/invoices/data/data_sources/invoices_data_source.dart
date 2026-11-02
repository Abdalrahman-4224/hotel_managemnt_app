import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class InvoicesDataSource {
  final ApiClient apiClient;

  InvoicesDataSource(this.apiClient);

  /// The booking with its `details` (rooms, guest, nights, price).
  Future<Map<String, dynamic>> fetchBooking(int bookingId) async {
    final data = await apiClient.get('/bookings/$bookingId');
    return data;
  }

  /// All transactions; the invoice keeps the ones for its booking.
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    final data = await apiClient.get('/transactions');
    return List<Map<String, dynamic>>.from(data);
  }
}

final invoicesDataSourceProvider = Provider<InvoicesDataSource>((ref) {
  return InvoicesDataSource(ref.watch(apiClientProvider));
});
