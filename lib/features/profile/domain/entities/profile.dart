class UserProfile {
  const UserProfile({
    required this.initial,
    required this.name,
    required this.role,
    required this.phone,
    required this.maskedPhone,
  });

  final String initial;
  final String name;
  final String role;
  final String phone;
  final String maskedPhone;
}

/// The signed-in user's hotel: what every staff member may see.
class Hotel {
  const Hotel({required this.id, required this.name, required this.roomsCount});

  final int id;
  final String name;
  final int roomsCount;
}

class PlanUsage {
  const PlanUsage(this.label, this.used, this.limit);

  final String label;
  final int used;
  final int limit;

  double get ratio => limit == 0 ? 0 : used / limit;
}

/// The hotel's subscription. Only for roles with SUBSCRIPTION_VIEW.
class Subscription {
  const Subscription({
    required this.name,
    required this.status,
    required this.endsOn,
    required this.daysLeft,
    required this.totalDays,
    required this.note,
    required this.usage,
  });

  final String name;
  final String status;
  final String endsOn;
  final int daysLeft;
  final int totalDays;
  final String note;
  final List<PlanUsage> usage;
}
