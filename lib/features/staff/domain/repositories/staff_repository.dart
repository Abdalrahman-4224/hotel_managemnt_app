import '../entities/staff_member.dart';

/// The hotel's staff.
/// The real implementation is in data/repositories/staff_repository_impl.dart.
abstract class StaffRepository {
  Future<List<StaffMember>> getStaff();

  /// Today's actions of one staff member, oldest first.
  Future<List<StaffActivity>> getActivity(int userId);
}
