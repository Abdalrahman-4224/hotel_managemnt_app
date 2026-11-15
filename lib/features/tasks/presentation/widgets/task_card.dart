import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/task_item.dart';

extension TaskTypeIcon on TaskType {
  IconData get icon => switch (this) {
    TaskType.maintenance => LucideIcons.wrench,
    TaskType.cleaning => LucideIcons.sparkles,
    TaskType.generalService => LucideIcons.conciergeBell,
  };
}

class TaskStatusTag extends StatelessWidget {
  const TaskStatusTag(this.status, {super.key});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) => NzTag(
    status.label,
    fontSize: 12,
    tone: switch (status) {
      TaskStatus.fresh => NzTagTone.gold,
      TaskStatus.inProgress => NzTagTone.dark,
      TaskStatus.done => NzTagTone.neutral,
    },
  );
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.personLine,
    required this.personInitial,
    this.actionLabel,
    this.actionPrimary = false,
    this.onAction,
  });

  final TaskItem task;
  final String personLine;
  final String personInitial;
  final String? actionLabel;
  final bool actionPrimary;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = task;
    final done = t.status == TaskStatus.done;
    final meta = AppText.body(12.5, color: AppColors.inkMuted);
    return Opacity(
      opacity: done ? .78 : 1,
      child: NzCard(
        radius: AppRadius.r20,
        shadow: AppShadows.card,
        borderColor: t.urgent && !done
            ? const Color(0x73B68235)
            : AppColors.line,
        padding: EdgeInsets.all(AppSpacing.s14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NzIconTile(t.type.icon, iconSize: 19.r),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.type.label,
                            style: AppText.body(12, color: AppColors.inkMuted),
                          ),
                          if (t.urgent) ...[
                            SizedBox(width: AppSpacing.s6),
                            NzTag(
                              'عاجلة',
                              tone: NzTagTone.dark,
                              height: 20.r,
                              fontSize: 11,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.s4),
                      Text(
                        t.title,
                        style: AppText.body(
                          15.5,
                          weight: FontWeight.w600,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s4),
                      Wrap(
                        spacing: AppSpacing.s12,
                        runSpacing: AppSpacing.s4,
                        children: [
                          if (t.location.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.mapPin,
                                  size: 13.r,
                                  color: AppColors.inkMuted,
                                ),
                                SizedBox(width: AppSpacing.s4),
                                Text(t.location, style: meta),
                              ],
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 13.r,
                                color: AppColors.inkMuted,
                              ),
                              SizedBox(width: AppSpacing.s4),
                              Text(
                                t.at,
                                style: AppText.num(
                                  12.5,
                                  weight: FontWeight.w400,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.s12),
                TaskStatusTag(t.status),
              ],
            ),
            SizedBox(height: AppSpacing.s12),
            const NzDivider(),
            SizedBox(height: AppSpacing.s10),
            Row(
              children: [
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: const BoxDecoration(
                    color: AppColors.inert,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    personInitial,
                    style: AppText.body(
                      11.5,
                      weight: FontWeight.w600,
                      color: AppColors.ink3,
                      height: 1,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    personLine,
                    style: AppText.body(13, color: AppColors.inkMuted),
                  ),
                ),
                if (actionLabel != null)
                  actionPrimary
                      ? NzPrimaryButton(
                          label: actionLabel!,
                          height: 40.r,
                          radius: AppRadius.r12,
                          fontSize: 13.5,
                          onPressed: onAction,
                        )
                      : NzOutlineButton(
                          label: actionLabel!,
                          height: 40.r,
                          radius: AppRadius.r12,
                          fontSize: 13.5,
                          weight: FontWeight.w600,
                          onPressed: onAction,
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
