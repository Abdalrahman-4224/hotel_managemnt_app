import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/campaign.dart';

/// A row from GET /campaigns.
class CampaignModel {
  final Map<String, dynamic> json;

  const CampaignModel(this.json);

  factory CampaignModel.fromJson(Map<String, dynamic> json) =>
      CampaignModel(json);

  /// From the statuses of the campaign's bookings, e.g. "CheckedIn,Confirmed".
  CampaignStatus get status {
    final statuses = (json['booking_statuses'] ?? '').toString();
    if (statuses.contains('CheckedIn')) return CampaignStatus.staying;
    if (statuses.contains('Confirmed') || statuses.isEmpty) {
      return CampaignStatus.upcoming;
    }
    return CampaignStatus.departed;
  }

  Campaign toEntity() {
    final rooms = (json['room_numbers'] ?? '').toString();
    return Campaign(
      id: parseInt(json['campaign_id'])!,
      name: json['name_campaign'] ?? '',
      manager: json['manager_name'] ?? '—',
      phone: json['manager_phone'] ?? '—',
      rooms: rooms.isEmpty ? const [] : rooms.split(', '),
      heads: parseInt(json['expected_guests_count']) ?? 0,
      checkIn: parseDate(json['check_in_date']),
      checkOut: parseDate(json['check_out_date']),
      status: status,
      total: parseDouble(json['total_amount']) ?? 0,
      paid: parseDouble(json['paid_amount']) ?? 0,
    );
  }
}
