import '../../domain/entities/dashboard_summary.dart';

/// Sample data from the design. Replace with an API data source.
class DashboardLocalDataSource {
  const DashboardLocalDataSource();

  DashboardSummary getSummary() => const DashboardSummary(
    hotelLine: 'فندق أ · بغداد',
    greeting: 'مساء الخير، أحمد',
    revenueUsd: '8,650',
    revenueIqd: '11,240,000',
    revenueNote: '14 حجزاً · نقد وبطاقة',
    occupancy: .72,
    arrivals: 9,
    arrivalsNote: 'منها حملة واحدة',
    departures: 6,
    departuresNote: '1 متأخرة',
    movements: [
      DailyMovement(
        initial: 'س',
        guest: 'سعد المطيري',
        room: '104',
        tag: 'وصول',
        kind: MovementKind.arrival,
      ),
      DailyMovement(
        initial: 'ش',
        guest: 'وفد شركة الأفق',
        room: '301–312',
        tag: 'وصول',
        kind: MovementKind.arrival,
      ),
      DailyMovement(
        initial: 'ل',
        guest: 'ليلى العتيبي',
        room: '305',
        tag: 'تأخر',
        kind: MovementKind.late,
      ),
      DailyMovement(
        initial: 'ه',
        guest: 'هند القحطاني',
        room: '118',
        tag: 'قادم 16:00',
        kind: MovementKind.upcoming,
      ),
    ],
  );
}
