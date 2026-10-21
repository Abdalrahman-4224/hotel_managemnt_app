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
    required this.department,
    required this.role,
    required this.online,
    required this.lastSeen,
    required this.bookings,
    required this.tasks,
    required this.usd,
    required this.iqd,
    required this.activity,
  });

  final String id;
  final String name;
  final String initial;
  final String department;
  final String role;
  final bool online;
  final String lastSeen;
  final int bookings;
  final int tasks;
  final int usd;
  final int iqd;

  /// Today's actions, oldest first.
  final List<StaffActivity> activity;
}
