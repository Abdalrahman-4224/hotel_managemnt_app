enum MovementKind { arrival, late, upcoming }

/// One row in "حركة اليوم" (today's arrivals / departures).
class DailyMovement {
  const DailyMovement({
    required this.initial,
    required this.guest,
    required this.room,
    required this.tag,
    required this.kind,
  });

  final String initial;
  final String guest;
  final String room;
  final String tag;
  final MovementKind kind;
}

class DashboardSummary {
  const DashboardSummary({
    required this.hotelLine,
    required this.greeting,
    required this.revenueUsd,
    required this.revenueIqd,
    required this.revenueNote,
    required this.occupancy,
    required this.arrivals,
    required this.arrivalsNote,
    required this.departures,
    required this.departuresNote,
    required this.movements,
  });

  final String hotelLine;
  final String greeting;
  final String revenueUsd;
  final String revenueIqd;
  final String revenueNote;
  final double occupancy;
  final int arrivals;
  final String arrivalsNote;
  final int departures;
  final String departuresNote;
  final List<DailyMovement> movements;
}
