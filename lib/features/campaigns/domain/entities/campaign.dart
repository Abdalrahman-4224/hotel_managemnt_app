enum CampaignStatus { staying, upcoming, departed }

extension CampaignStatusX on CampaignStatus {
  String get label => switch (this) {
    CampaignStatus.staying => 'مقيمة',
    CampaignStatus.upcoming => 'قادمة',
    CampaignStatus.departed => 'مغادرة',
  };

  String get tabLabel => switch (this) {
    CampaignStatus.staying => 'المقيمة',
    CampaignStatus.upcoming => 'القادمة',
    CampaignStatus.departed => 'المغادرة',
  };

  String get action => switch (this) {
    CampaignStatus.staying => 'تسوية ومغادرة',
    CampaignStatus.upcoming => 'تسجيل دخول الحملة',
    CampaignStatus.departed => 'الفاتورة',
  };
}

/// An amount held in both currencies (`—` when unused).
class DualAmount {
  const DualAmount(this.usd, this.iqd);

  final String usd;
  final String iqd;

  /// The first currency in use, with a short unit suffix.
  String get short => usd != '—' ? '$usd \$' : '$iqd د.ع';
}

class CampaignMember {
  const CampaignMember(this.name, this.room, this.nights, this.amount);

  final String name;
  final String room;
  final String nights;
  final String amount;

  String get initial => name.substring(0, 1);
}

class CampaignEvent {
  const CampaignEvent(this.what, this.when);

  final String what;
  final String when;
}

class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.manager,
    required this.phone,
    required this.rooms,
    required this.heads,
    required this.nights,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.priceBasis,
    required this.document,
    required this.total,
    required this.paid,
    required this.due,
    required this.paidPercent,
    required this.members,
    required this.trail,
  });

  final String id;
  final String name;
  final String manager;
  final String phone;
  final List<String> rooms;
  final int heads;
  final int nights;
  final String checkIn;
  final String checkOut;
  final CampaignStatus status;
  final String priceBasis;
  final String document;
  final DualAmount total;
  final DualAmount paid;
  final DualAmount due;
  final int paidPercent;
  final List<CampaignMember> members;
  final List<CampaignEvent> trail;

  String get dateRange =>
      '${checkIn.split(' · ').first}  ←  ${checkOut.split(' · ').first}';
}
