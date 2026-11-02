import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/repositories/invoices_repository.dart';
import '../data_sources/invoices_data_source.dart';
import '../models/invoice_model.dart';

class InvoicesRepositoryImpl implements InvoicesRepository {
  final InvoicesDataSource dataSource;

  InvoicesRepositoryImpl(this.dataSource);

  @override
  Future<Invoice> getInvoice(
    int bookingId, {
    required String hotelName,
    required String staff,
  }) async {
    final (booking, transactions) = await (
      dataSource.fetchBooking(bookingId),
      dataSource.fetchTransactions(),
    ).wait;
    return InvoiceModel.fromJson(
      booking: booking,
      transactions: transactions,
      hotelName: hotelName,
      staff: staff,
    );
  }
}

final invoicesRepositoryProvider = Provider<InvoicesRepository>((ref) {
  return InvoicesRepositoryImpl(ref.watch(invoicesDataSourceProvider));
});
