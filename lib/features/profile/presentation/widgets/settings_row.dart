import 'package:flutter/material.dart';
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
      constraints: const BoxConstraints(minHeight: 58),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            NzIconTile(
              icon,
              tone: NzIconTileTone.inert,
              size: 36,
              radius: 12,
              iconSize: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppText.body(15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppText.body(12.5, color: AppColors.inkMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 12),
              Text(value!, style: AppText.body(13, color: AppColors.inkMuted)),
            ],
            const SizedBox(width: 12),
            trailing ??
                const Icon(
                  LucideIcons.chevronLeft,
                  size: 16,
                  color: AppColors.inkFaint,
                ),
          ],
        ),
      ),
    );
    if (trailing != null) return row;
    return InkWell(onTap: onTap ?? () {}, child: row);
  }
}
