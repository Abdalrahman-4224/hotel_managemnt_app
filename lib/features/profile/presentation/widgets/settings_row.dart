import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';

/// Settings list row: inert icon tile, title (+ optional subtitle),
/// optional value, and either a chevron or a custom [trailing] (switch).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: 58.r),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: AppSpacing.s10,
        ),
        child: Row(
          children: [
            NzIconTile(
              icon,
              tone: NzIconTileTone.inert,
              size: 36.r,
              radius: AppRadius.r12,
              iconSize: 18.r,
            ),
            SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppText.body(15)),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      subtitle!,
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              SizedBox(width: AppSpacing.s12),
              Text(value!, style: AppText.body(13, color: AppColors.inkMuted)),
            ],
            // A chevron only on rows that open something; an info row has none,
            // so nothing looks tappable unless it is.
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.s12),
              trailing!,
            ] else if (onTap != null) ...[
              SizedBox(width: AppSpacing.s12),
              Icon(
                LucideIcons.chevronLeft,
                size: 16.r,
                color: AppColors.inkFaint,
              ),
            ],
          ],
        ),
      ),
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
