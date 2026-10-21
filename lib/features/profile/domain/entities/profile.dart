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

class PlanUsage {
  const PlanUsage(this.label, this.used, this.limit);

  final String label;
  final int used;
  final int limit;

  double get ratio => limit == 0 ? 0 : used / limit;
}

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

class RenewalTerm {
  const RenewalTerm(this.label, this.note, this.price);

  final String label;
  final String note;
  final String price;
}
