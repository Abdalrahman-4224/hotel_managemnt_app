import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';

/// Shortcut tile in the "الأقسام" grid. The [featured] tile is dark.
class SectionTile extends StatelessWidget {
  const SectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.featured = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: AppRadius.r20,
      color: featured ? AppColors.ink : AppColors.card,
      borderColor: featured ? AppColors.ink : AppColors.line,
      shadow: AppShadows.card,
      padding: EdgeInsets.all(AppSpacing.s14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 88.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NzIconTile(
                  icon,
                  tone: featured
                      ? NzIconTileTone.solidGold
                      : NzIconTileTone.tint,
                ),
                Icon(
                  LucideIcons.chevronLeft,
                  size: 16.r,
                  color: featured ? AppColors.onInkMuted : AppColors.inkMuted,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.body(
                    15.5,
                    weight: FontWeight.w600,
                    color: featured ? AppColors.onInk : AppColors.ink,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: AppSpacing.s4),
                Text(
                  subtitle,
                  style: AppText.body(
                    12.5,
                    color: featured ? AppColors.onInkMuted : AppColors.inkMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
