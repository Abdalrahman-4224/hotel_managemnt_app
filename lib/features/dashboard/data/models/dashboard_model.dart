import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/dashboard_summary.dart';

/// GET /dashboard → the home screen numbers.
class DashboardModel {
  const DashboardModel._();

  static DashboardSummary fromJson(Map<String, dynamic> json) {
    // Revenue: one row per currency.
    var usd = 0.0;
    var iqd = 0.0;
    var payments = 0;
    for (final row in List<Map<String, dynamic>>.from(json['revenue_today'])) {
      final total = parseDouble(row['total']) ?? 0;
      if (row['currency'] == 'IQD') {
        iqd += total;
      } else {
        usd += total;
      }
      payments += parseInt(row['count']) ?? 0;
    }

    final totalRooms = parseInt(json['total_rooms']) ?? 0;
    final occupied = parseInt(json['occupied_rooms']) ?? 0;

    final movements = _movements(
      List<Map<String, dynamic>>.from(json['movements']),
    );
    final arrivals = movements.where((m) => m.$1 == 'arrival').toList();
    final departures = movements.where((m) => m.$1 == 'departure').toList();
    final groups = arrivals.where((m) => m.$3).length;
    final late = departures.where((m) => m.$2.kind == MovementKind.late).length;

    return DashboardSummary(
      revenueUsd: fmtNum(usd),
      revenueIqd: fmtNum(iqd),
      revenueNote: '$payments حركة قبض اليوم',
      occupancy: totalRooms == 0 ? 0 : occupied / totalRooms,
      arrivals: arrivals.length,
      arrivalsNote: groups == 0 ? 'لا حملات' : 'منها $groups حملة',
      departures: departures.length,
      departuresNote: late == 0 ? 'لا تأخير' : '$late متأخرة',
      movements: [for (final m in movements) m.$2],
    );
  }

  /// One line per individual booking, and one per campaign (its rooms together).
  /// Returns (movement, line, isGroup).
  static List<(String, DailyMovement, bool)> _movements(
    List<Map<String, dynamic>> rows,
  ) {
    // Rows of the same campaign (and the same movement) go into one group.
    final groups = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final id = row['campaign_id'] != null
          ? 'c${row['campaign_id']}'
          : 'b${row['booking_id']}';
      groups.putIfAbsent('$id-${row['movement']}', () => []).add(row);
    }

    final today = DateTime.now();
    final out = <(String, DailyMovement, bool)>[];
    for (final group in groups.values) {
      final first = group.first;
      final isGroup = first['campaign_id'] != null;
      final String guest =
          (isGroup ? first['name_campaign'] : first['guest_name']) ?? '—';
      final rooms = [for (final r in group) '${r['room_number']}'];
      final movement = first['movement'] as String;
      final (tag, kind) = _tag(first, movement, today);

      out.add((
        movement,
        DailyMovement(
          initial: guest.isEmpty ? '؟' : guest.substring(0, 1),
          guest: guest,
          room: rooms.length > 3 ? '${rooms.length} غرف' : rooms.join('، '),
          tag: tag,
          kind: kind,
        ),
        isGroup,
      ));
    }
    return out;
  }

  static (String, MovementKind) _tag(
    Map<String, dynamic> row,
    String movement,
    DateTime today,
  ) {
    if (movement == 'arrival') {
      return row['booking_status'] == 'CheckedIn'
          ? ('وصل', MovementKind.arrival)
          : ('قادم', MovementKind.upcoming);
    }
    final checkOut = parseDate(row['check_out_date']);
    return isSameDay(checkOut, today)
        ? ('مغادرة اليوم', MovementKind.upcoming)
        : ('تأخر', MovementKind.late);
  }
}
