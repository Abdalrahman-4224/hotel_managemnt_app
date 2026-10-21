import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/staff_member.dart';

class StaffTable extends StatelessWidget {
  const StaffTable({super.key, required this.staff, required this.onOpen});

  final List<StaffMember> staff;
  final ValueChanged<StaffMember> onOpen;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 18,
      shadow: AppShadows.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NzTableHead(
            cells: [
              ('الموظف · الدور', 1, null, TextAlign.start),
              ('حجوزات', null, 60, TextAlign.center),
              ('مهام', null, 52, TextAlign.center),
            ],
          ),
          for (var i = 0; i < staff.length; i++) ...[
            if (i > 0) const NzDivider(),
            _StaffRow(member: staff[i], onTap: () => onOpen(staff[i])),
          ],
        ],
      ),
    );
  }
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.member, required this.onTap});

  final StaffMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final m = member;
    return Semantics(
      button: true,
      label: '${m.name} — عرض السجل',
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 62),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          NzInitialAvatar(m.initial),
                          PositionedDirectional(
                            bottom: -1,
                            end: -1,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: m.online
                                    ? AppColors.gold
                                    : const Color(0xFFCFCBC6),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(
                                14.5,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${m.role} · ${m.online ? m.lastSeen : 'غير متصل'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(
                                12,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${m.bookings}',
                    textAlign: TextAlign.center,
                    style: AppText.num(15, height: 1),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${m.tasks}',
                    textAlign: TextAlign.center,
                    style: AppText.num(15, height: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityTable extends StatelessWidget {
  const ActivityTable({super.key, required this.items});

  final List<StaffActivity> items;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const NzTableHead(
            cells: [
              ('الوقت', null, 58, TextAlign.start),
              ('الإجراء', 1, null, TextAlign.start),
              ('المبلغ', null, 82, TextAlign.end),
            ],
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const NzDivider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 58,
                    child: Text(
                      items[i].time,
                      style: AppText.num(
                        12.5,
                        color: AppColors.ink3,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[i].description,
                      style: AppText.body(13.5, height: 1.55),
                    ),
                  ),
                  SizedBox(
                    width: 82,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          items[i].amount,
                          style: AppText.num(13, height: 1.4),
                        ),
                        if (items[i].currency.isNotEmpty)
                          Text(
                            items[i].currency,
                            style: AppText.body(11, color: AppColors.inkFaint),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
