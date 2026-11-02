import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../data_sources/finance_data_source.dart';
import '../models/transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceDataSource dataSource;

  FinanceRepositoryImpl(this.dataSource);

  @override
  Future<List<FinanceTransaction>> getTransactions() async {
    final rows = await dataSource.fetchTransactions();
    final list = rows.map(TransactionModel.fromJson).toList();
    list.sort((a, b) => b.when.compareTo(a.when));
    return list;
  }

  @override
  Future<void> addTransaction(NewTransaction transaction) {
    return dataSource.createTransaction(
      TransactionModel.newToJson(transaction),
    );
  }
}

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepositoryImpl(ref.watch(financeDataSourceProvider));
});
