import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/rooms_local_data_source.dart';
import '../../domain/entities/room.dart';
import '../widgets/room_widgets.dart';

/// Floor-by-floor room map with status filters.
class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final _floors = const RoomsLocalDataSource().getFloors();

  /// Statuses changed in this session (room number → status).
  final _overrides = <String, RoomStatus>{};
  var _floor = 0;
  RoomStatus? _filter;

  RoomStatus _statusOf(Room r) => _overrides[r.number] ?? r.status;

  @override
  Widget build(BuildContext context) {
    final all = [for (final f in _floors) ...f.rooms];
    final floor = _floors[_floor];
    final list = floor.rooms
        .where((r) => _filter == null || _statusOf(r) == _filter)
        .toList();
    final free = all.where((r) => _statusOf(r) == RoomStatus.free).length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle: '$free غرفة متاحة من ${all.length}',
                title: 'خريطة الغرف',
                actions: [
                  NzIconButton(
                    icon: LucideIcons.search,
                    tooltip: 'بحث عن غرفة',
                    onPressed: () {},
                  ),
                ],
                bottomBleeds: true,
                bottom: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: NzPillScroller(
                    children: [
                      for (final (i, f) in _floors.indexed)
                        NzChoicePill(
                          label: f.name,
                          count: '${f.rooms.length}',
                          selected: _floor == i,
                          onTap: () => setState(() => _floor = i),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 14,
                    bottom: NzBottomNav.bodyPadding(context) + 72,
                  ),
                  children: [
                    NzPillScroller(
                      children: [
                        for (final st in RoomStatus.values)
                          NzChoicePill(
                            label: st.label,
                            leading: RoomStatusDot(st),
                            count:
                                '${floor.rooms.where((r) => _statusOf(r) == st).length}',
                            selected: _filter == st,
                            onTap: () => setState(
                              () => _filter = _filter == st ? null : st,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: list.isEmpty
                          ? NzDashedBox(
                              padding: const EdgeInsets.symmetric(
                                vertical: 32,
                                horizontal: 12,
                              ),
                              child: Text(
                                'لا غرف بهذه الحالة في هذا الطابق.',
                                textAlign: TextAlign.center,
                                style: AppText.body(
                                  14,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            )
                          : NzGrid(
                              children: [
                                for (final r in list)
                                  RoomTile(
                                    room: r,
                                    status: _statusOf(r),
                                    onTap: () => _openRoom(r),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          PositionedDirectional(
            end: 16,
            bottom: NzBottomNav.fabBottom(context),
            child: NzFloatingButton(
              label: 'حجز جديد',
              onPressed: () => context.push(AppRoutes.addBooking),
            ),
          ),
        ],
      ),
    );
  }

  void _openRoom(Room room) {
    final floorName = _floors.firstWhere((f) => f.rooms.contains(room)).name;
    showNzSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      gap: 16,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final st = _statusOf(room);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'غرفة ${room.number}',
                      style: AppText.display(22),
                    ),
                  ),
                  RoomStatusTag(st),
                ],
              ),
              const SizedBox(height: 16),
              NzGrid(
                columns: 2,
                children: [
                  _Fact('النوع', room.type),
                  _Fact('الأسرّة', room.beds),
                  _Fact('الطابق', floorName),
                  _Fact('الإطلالة', room.view),
                ],
              ),
              const SizedBox(height: 16),
              if (st == RoomStatus.busy)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldTint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.goldBorderSoft),
                  ),
                  child: Text(
                    'الغرفة مشغولة بنزيل — تتغيّر حالتها تلقائياً عند تسجيل الخروج.',
                    style: AppText.body(
                      13.5,
                      color: AppColors.goldDarkest,
                      height: 1.6,
                    ),
                  ),
                )
              else ...[
                Text(
                  'حالة الغرفة',
                  style: AppText.body(13, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final (i, o) in const [
                      RoomStatus.free,
                      RoomStatus.held,
                      RoomStatus.maintenance,
                    ].indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: NzChoicePill(
                          label: o.label,
                          selected: st == o,
                          height: 48,
                          radius: 14,
                          fontSize: 14.5,
                          offColor: AppColors.ink,
                          onTap: () {
                            setState(() => _overrides[room.number] = o);
                            setSheet(() {});
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'الحالة الافتراضية لأي غرفة: متاحة.',
                  style: AppText.body(12.5, color: AppColors.inkFaint),
                ),
              ],
              const SizedBox(height: 16),
              NzPrimaryButton(
                label: 'تم',
                height: 52,
                weight: FontWeight.w500,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return NzCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.body(12, color: AppColors.inkMuted)),
          const SizedBox(height: 3),
          Text(value, style: AppText.body(14.5, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
