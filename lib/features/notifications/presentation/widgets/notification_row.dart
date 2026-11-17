import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/app_notification.dart';

/// The icons the server names, in the order it sends them. Anything new it
/// starts sending falls back to the bell rather than showing nothing.
const _icons = <String, IconData>{
  'alarm-clock': LucideIcons.alarmClock,
  'check-check': LucideIcons.checkCheck,
  'clipboard-check': LucideIcons.clipboardCheck,
  'clipboard-list': LucideIcons.clipboardList,
  'clock': LucideIcons.clock,
  'door-open': LucideIcons.doorOpen,
  'hand-platter': LucideIcons.handPlatter,
  'sparkles': LucideIcons.sparkles,
  'wrench': LucideIcons.wrench,
  'x': LucideIcons.x,
  'bell': LucideIcons.bell,
};

IconData iconFor(String name) => _icons[name] ?? LucideIcons.bell;

/// `منذ 5 دقائق`, `أمس`, then the date once it is older than a week.
String timeAgo(DateTime at, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(at);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
  if (diff.inDays == 1) return 'أمس';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
  return '${at.day}/${at.month}/${at.year}';
}

/// One row of the inbox. An unread one is tinted and carries a gold dot.
class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final unread = !n.isRead;
    return NzCard(
      radius: AppRadius.r16,
      color: unread ? AppColors.goldTint : AppColors.card,
      borderColor: unread ? AppColors.goldBorderSoft : AppColors.line,
      shadow: unread ? AppShadows.card : null,
      padding: EdgeInsets.all(AppSpacing.s12),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NzIconTile(
            iconFor(n.icon),
            tone: n.urgent ? NzIconTileTone.ink : NzIconTileTone.tint,
            size: 38.r,
            radius: AppRadius.r12,
            iconSize: 18.r,
          ),
          SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(
                          14.5,
                          weight: unread ? FontWeight.w600 : FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (n.urgent) ...[
                      SizedBox(width: AppSpacing.s6),
                      NzTag(
                        'عاجل',
                        tone: NzTagTone.dark,
                        height: 20.r,
                        fontSize: 11,
                      ),
                    ],
                  ],
                ),
                if (n.body.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.s2),
                  Text(
                    n.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      13,
                      color: AppColors.inkMuted,
                      height: 1.5,
                    ),
                  ),
                ],
                SizedBox(height: AppSpacing.s6),
                Text(
                  timeAgo(n.createdAt),
                  style: AppText.body(11.5, color: AppColors.inkFaint),
                ),
              ],
            ),
          ),
          if (unread) ...[
            SizedBox(width: AppSpacing.s8),
            Container(
              margin: EdgeInsets.only(top: AppSpacing.s6),
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
