import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../domain/entities/campaign.dart';
import '../controllers/campaigns_controller.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_sheet.dart';

class CampaignsScreen extends ConsumerStatefulWidget {
  const CampaignsScreen({super.key});

  @override
  ConsumerState<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends ConsumerState<CampaignsScreen> {
  CampaignStatus? _tab;

  Future<void> _nextStep(Campaign c) async {
    try {
      await ref.read(campaignsControllerProvider.notifier).nextStep(c);
      if (mounted && c.status != CampaignStatus.departed) {
        showNzToast(context, 'تم تحديث الحملة');
      }
    } catch (error) {
      if (mounted) showNzToast(context, errorText(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(campaignsControllerProvider);
    final can = ref.watch(canProvider);
    final camps = async.value ?? const <Campaign>[];
    int count(CampaignStatus s) => camps.where((c) => c.status == s).length;
    final list = camps.where((c) => _tab == null || c.status == _tab).toList();
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle:
                    '${count(CampaignStatus.staying)} مقيمة · ${count(CampaignStatus.upcoming)} قادمة',
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
                child: NzAsyncBody(
                  hasValue: async.hasValue,
                  error: async.error,
                  onRetry: () =>
                      ref.read(campaignsControllerProvider.notifier).refresh(),
                  child: () => RefreshIndicator(
                    onRefresh: () => ref
                        .read(campaignsControllerProvider.notifier)
                        .refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                              style: AppText.body(
                                14,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ),
                        for (final (i, c) in list.indexed) ...[
                          if (i > 0) const SizedBox(height: 12),
                          CampaignCard(
                            campaign: c,
                            onTap: () => showCampaignSheet(
                              context,
                              c,
                              onAction: () => _nextStep(c),
                              canAct:
                                  c.status != CampaignStatus.departed &&
                                  can.can(Permissions.bookingCheckIn),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (can.can(Permissions.campaignCreate) &&
              can.can(Permissions.bookingCreate))
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
