import '../../../../core/utils/formatters.dart';

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
    CampaignStatus.departed => 'إغلاق',
  };
}

/// A group booking. Amounts are in US dollars.
class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.manager,
    required this.phone,
    required this.rooms,
    required this.heads,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.total,
    required this.paid,
  });

  final int id;
  final String name;
  final String manager;
  final String phone;
  final List<String> rooms;
  final int heads;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final CampaignStatus status;
  final double total;
  final double paid;

  double get due => total - paid < 0 ? 0 : total - paid;

  int get nights => checkIn == null || checkOut == null
      ? 0
      : checkOut!.difference(checkIn!).inDays;

  int get paidPercent => total <= 0 ? 0 : (paid * 100 / total).round();

  String get dateRange => '${fmtDate(checkIn)}  ←  ${fmtDate(checkOut)}';
}
