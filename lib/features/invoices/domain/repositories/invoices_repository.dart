import '../entities/invoice.dart';

/// Guest invoices.
/// The real implementation is in data/repositories/invoices_repository_impl.dart.
abstract class InvoicesRepository {
  /// [hotelName] and [staff] (who issues it) are printed on the invoice.
  Future<Invoice> getInvoice(
    int bookingId, {
    required String hotelName,
    required String staff,
  });
}
