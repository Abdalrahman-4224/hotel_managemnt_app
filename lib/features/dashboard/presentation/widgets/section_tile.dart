import 'package:flutter/material.dart';
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
      radius: 20,
      color: featured ? AppColors.ink : AppColors.card,
      borderColor: featured ? AppColors.ink : AppColors.line,
      shadow: AppShadows.card,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
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
                  size: 16,
                  color: featured ? AppColors.onInkMuted : AppColors.inkMuted,
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                const SizedBox(height: 4),
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
