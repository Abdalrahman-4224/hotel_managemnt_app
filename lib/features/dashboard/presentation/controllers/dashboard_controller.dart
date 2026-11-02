import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Today's numbers for the home screen. Invalidate it to reload
/// (bookings do this after check-in / check-out).
final dashboardProvider = FutureProvider<DashboardSummary>((ref) {
  ref.watch(authControllerProvider.select((s) => s.user?.id));
  return ref.read(dashboardRepositoryProvider).getSummary();
});
