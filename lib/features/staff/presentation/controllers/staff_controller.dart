import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/staff_repository_impl.dart';
import '../../domain/entities/staff_member.dart';

/// The hotel's staff. Also used by the task form to pick who gets a task.
class StaffController extends AsyncNotifier<List<StaffMember>> {
  @override
  Future<List<StaffMember>> build() {
    return ref.read(staffRepositoryProvider).getStaff();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(staffRepositoryProvider).getStaff(),
    );
  }
}

final staffControllerProvider =
    AsyncNotifierProvider<StaffController, List<StaffMember>>(
      StaffController.new,
    );

/// One staff member's activity today, loaded when their page opens.
final staffActivityProvider = FutureProvider.family<List<StaffActivity>, int>((
  ref,
  userId,
) {
  return ref.read(staffRepositoryProvider).getActivity(userId);
});
