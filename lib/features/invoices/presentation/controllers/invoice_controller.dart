import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/controllers/subscription_controller.dart';
import '../../data/repositories/invoices_repository_impl.dart';
import '../../domain/entities/invoice.dart';

/// The invoice of one booking.
final invoiceProvider = FutureProvider.autoDispose.family<Invoice, int>((
  ref,
  bookingId,
) async {
  final hotel = await ref.watch(subscriptionProvider.future);
  final user = ref.read(authControllerProvider).user;
  return ref
      .read(invoicesRepositoryProvider)
      .getInvoice(
        bookingId,
        hotelName: hotel.hotelName,
        staff: user?.fullName ?? '—',
      );
});
