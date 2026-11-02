import '../entities/finance_transaction.dart';

/// Money movements.
/// The real implementation is in data/repositories/finance_repository_impl.dart.
abstract class FinanceRepository {
  /// Newest first.
  Future<List<FinanceTransaction>> getTransactions();
  Future<void> addTransaction(NewTransaction transaction);
}
