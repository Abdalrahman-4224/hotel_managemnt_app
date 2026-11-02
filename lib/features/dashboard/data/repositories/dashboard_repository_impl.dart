import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../data_sources/dashboard_data_source.dart';
import '../models/dashboard_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource dataSource;

  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<DashboardSummary> getSummary() async {
    final json = await dataSource.fetchSummary();
    return DashboardModel.fromJson(json);
  }
}

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardDataSourceProvider));
});
