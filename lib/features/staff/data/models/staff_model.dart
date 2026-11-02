import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/staff_member.dart';

/// Rows from GET /users/staff and GET /users/staff/:id/activity.
class StaffModel {
  const StaffModel._();

  static StaffMember memberFromJson(Map<String, dynamic> json) {
    final name = (json['full_name'] ?? '').toString();
    return StaffMember(
      id: parseInt(json['user_id'])!,
      name: name,
      initial: name.isEmpty ? '؟' : name.substring(0, 1),
      departmentId: parseInt(json['department_id']),
      department: json['department_name'] ?? '—',
      role: json['role_name'] ?? '',
      bookings: parseInt(json['bookings_today']) ?? 0,
      tasks: parseInt(json['open_tasks']) ?? 0,
      usd: (parseDouble(json['usd_today']) ?? 0).round(),
      iqd: (parseDouble(json['iqd_today']) ?? 0).round(),
    );
  }

  static StaffActivity activityFromJson(Map<String, dynamic> json) {
    final time = fmtTime(parseDate(json['at']));
    final amount = parseDouble(json['amount']);
    final note = json['note'] ?? '';
    switch (json['kind']) {
      case 'booking':
        return StaffActivity(
          time,
          'أنشأ حجز #${json['ref_id']}',
          usd: amount == null ? null : fmtNum(amount),
        );
      case 'payment':
        final text = 'سجّل حركة مالية${note == '' ? '' : ' — $note'}';
        final value = amount == null ? null : fmtNum(amount);
        return json['currency'] == 'IQD'
            ? StaffActivity(time, text, iqd: value)
            : StaffActivity(time, text, usd: value);
      default:
        return StaffActivity(time, 'أنهى مهمة — $note');
    }
  }
}
