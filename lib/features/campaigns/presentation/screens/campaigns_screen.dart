import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/campaigns_local_data_source.dart';
import '../../domain/entities/campaign.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_sheet.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final _camps = const CampaignsLocalDataSource().getCampaigns();
  CampaignStatus? _tab;

  int _count(CampaignStatus s) => _camps.where((c) => c.status == s).length;

  @override
  Widget build(BuildContext context) {
    final list = _camps.where((c) => _tab == null || c.status == _tab).toList();
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle:
                    '${_count(CampaignStatus.staying)} مقيمة · ${_count(CampaignStatus.upcoming)} قادمة',
                title: 'الحملات',
                bottom: NzSegmented<CampaignStatus?>(
                  selected: _tab,
                  height: 42,
                  fontSize: 13.5,
                  onChanged: (v) => setState(() => _tab = v),
                  segments: [
                    const NzSegment(null, 'الكل'),
                    for (final s in CampaignStatus.values)
                      NzSegment(s, s.tabLabel),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    NzBottomNav.bodyPadding(context) + 76,
                  ),
                  children: [
                    if (list.isEmpty)
                      NzDashedBox(
                        child: Text(
                          'لا حملات في هذا التصنيف.',
                          textAlign: TextAlign.center,
                          style: AppText.body(14, color: AppColors.inkMuted),
                        ),
                      ),
                    for (final (i, c) in list.indexed) ...[
                      if (i > 0) const SizedBox(height: 12),
                      CampaignCard(
                        campaign: c,
                        onTap: () => showCampaignSheet(context, c),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          PositionedDirectional(
            end: 16,
            bottom: NzBottomNav.fabBottom(context),
            child: NzFloatingButton(
              label: 'حملة جديدة',
              icon: LucideIcons.plus,
              onPressed: () => context.push(AppRoutes.addBooking),
            ),
          ),
        ],
      ),
    );
  }
}
