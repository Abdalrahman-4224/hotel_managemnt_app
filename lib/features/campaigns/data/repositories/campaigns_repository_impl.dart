import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/campaign.dart';
import '../../domain/repositories/campaigns_repository.dart';
import '../data_sources/campaigns_data_source.dart';
import '../models/campaign_model.dart';

class CampaignsRepositoryImpl implements CampaignsRepository {
  final CampaignsDataSource dataSource;

  CampaignsRepositoryImpl(this.dataSource);

  @override
  Future<List<Campaign>> getCampaigns() async {
    final rows = await dataSource.fetchCampaigns();
    return rows.map((json) => CampaignModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<void> checkIn(Campaign campaign) => dataSource.checkIn(campaign.id);

  @override
  Future<void> checkOut(Campaign campaign) => dataSource.checkOut(campaign.id);
}

final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  return CampaignsRepositoryImpl(ref.watch(campaignsDataSourceProvider));
});
