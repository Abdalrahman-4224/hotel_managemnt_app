import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/staff_repository.dart';
import '../data_sources/staff_data_source.dart';
import '../models/staff_model.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffDataSource dataSource;

  StaffRepositoryImpl(this.dataSource);

  @override
  Future<List<StaffMember>> getStaff() async {
    final rows = await dataSource.fetchStaff();
    return rows.map(StaffModel.memberFromJson).toList();
  }

  @override
  Future<List<StaffActivity>> getActivity(int userId) async {
    final rows = await dataSource.fetchActivity(userId);
    return rows.map(StaffModel.activityFromJson).toList();
  }
}

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  return StaffRepositoryImpl(ref.watch(staffDataSourceProvider));
});
