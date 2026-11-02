import '../entities/dashboard_summary.dart';

/// The home screen numbers.
/// The real implementation is in data/repositories/dashboard_repository_impl.dart.
abstract class DashboardRepository {
  Future<DashboardSummary> getSummary();
}
