class StaffActivity {
  const StaffActivity(this.time, this.description, {this.usd, this.iqd});

  final String time;
  final String description;
  final String? usd;
  final String? iqd;

  String get amount => usd ?? iqd ?? '—';
  String get currency => usd != null
      ? 'دولار'
      : iqd != null
      ? 'دينار'
      : '';
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.initial,
    required this.departmentId,
    required this.department,
    required this.role,
    required this.bookings,
    required this.tasks,
    required this.usd,
    required this.iqd,
  });

  final int id;
  final String name;
  final String initial;
  final int? departmentId;
  final String department;
  final String role;

  /// Bookings created today.
  final int bookings;

  /// Tasks assigned and not finished.
  final int tasks;

  /// Money recorded today, per currency.
  final int usd;
  final int iqd;

  /// The server has no live presence, so "online" means "did some work today".
  bool get online => bookings > 0 || usd > 0 || iqd > 0;

  String get lastSeen => online ? 'نشط اليوم' : 'لا نشاط اليوم';
}
