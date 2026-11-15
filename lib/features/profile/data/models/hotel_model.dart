import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/profile.dart';

/// GET /hotels/current and GET /hotels/current/subscription.
class HotelModel {
  const HotelModel._();

  static Hotel hotelFromJson(Map<String, dynamic> json) {
    return Hotel(
      id: parseInt(json['hotel_id']) ?? 0,
      name: json['name'] ?? '',
      roomsCount: parseInt(json['rooms_count']) ?? 0,
    );
  }

  static Subscription subscriptionFromJson(Map<String, dynamic> json) {
    final start = parseDate(json['current_subscreption_start_date']);
    final end = parseDate(json['current_subscreption_end_date']);
    final now = DateTime.now();
    final daysLeft = end == null ? 0 : end.difference(now).inDays;
    final totalDays = start == null || end == null
        ? 1
        : end.difference(start).inDays;
    return Subscription(
      name: 'اشتراك الفندق',
      status: json['status'] == 'Active' ? 'نشط' : 'متوقف',
      endsOn: fmtDate(end),
      daysLeft: daysLeft < 0 ? 0 : daysLeft,
      totalDays: totalDays < 1 ? 1 : totalDays,
      note: 'للتجديد تواصل مع إدارة المنصة',
      usage: [
        PlanUsage(
          'الغرف',
          parseInt(json['rooms_count']) ?? 0,
          parseInt(json['rooms_total']) ?? 0,
        ),
      ],
    );
  }
}
