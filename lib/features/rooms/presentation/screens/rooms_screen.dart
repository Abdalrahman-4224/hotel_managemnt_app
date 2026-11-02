import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../domain/entities/floors.dart';
import '../../domain/entities/room.dart';
import '../controllers/floors_controller.dart';
import '../widgets/room_widgets.dart';

/// Floor-by-floor room map with status filters.
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  var _floor = 0;
  RoomStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(floorsControllerProvider);
    // Keep showing the last floors while reloading.
    final floors = async.value ?? const <Floor>[];
    final all = [for (final f in floors) ...f.rooms];
    final free = all.where((r) => r.status == RoomStatus.free).length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                subtitle: async.hasValue
                    ? '$free غرفة متاحة من ${all.length}'
                    : 'جارٍ التحميل…',
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
                      for (final (i, f) in floors.indexed)
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
              Expanded(child: _body(async, floors)),
            ],
          ),
          if (ref.watch(canProvider).can(Permissions.bookingCreate))
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

  Widget _body(AsyncValue<List<Floor>> async, List<Floor> floors) {
    // First load: nothing to show yet.
    if (!async.hasValue) {
      if (async.hasError) {
        return _Message(
          text: _errorText(async.error),
          action: NzPrimaryButton(
            label: 'إعادة المحاولة',
            height: 48,
            onPressed: () =>
                ref.read(floorsControllerProvider.notifier).refresh(),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    if (floors.isEmpty) {
      return const _Message(text: 'لا توجد طوابق في هذا الفندق بعد.');
    }

    // Floors can change after a refresh, so keep the index in range.
    final floor = floors[_floor.clamp(0, floors.length - 1)];
    final list = floor.rooms
        .where((r) => _filter == null || r.status == _filter)
        .toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(floorsControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  count: '${floor.rooms.where((r) => r.status == st).length}',
                  selected: _filter == st,
                  onTap: () =>
                      setState(() => _filter = _filter == st ? null : st),
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
                      floor.rooms.isEmpty
                          ? 'لا غرف في هذا الطابق.'
                          : 'لا غرف بهذه الحالة في هذا الطابق.',
                      textAlign: TextAlign.center,
                      style: AppText.body(14, color: AppColors.inkMuted),
                    ),
                  )
                : NzGrid(
                    children: [
                      for (final r in list)
                        RoomTile(
                          room: r,
                          status: r.status,
                          onTap: () => _openRoom(r, floor.name),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _errorText(Object? error) =>
      error is AppException ? error.message : 'حدث خطأ ما، حاول مرة أخرى';

  Future<void> _changeStatus(Room room, RoomStatus status) async {
    try {
      await ref
          .read(floorsControllerProvider.notifier)
          .setRoomStatus(room, status);
    } catch (error) {
      if (mounted) showNzToast(context, _errorText(error));
    }
  }

  void _openRoom(Room tapped, String floorName) {
    final canSetStatus = ref.read(canProvider).can(Permissions.roomUpdate);
    showNzSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
      gap: 16,
      // Consumer: rebuild the sheet when the room's status changes.
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final floors = ref.watch(floorsControllerProvider).value ?? [];
          final room = [for (final f in floors) ...f.rooms]
              .firstWhere((r) => r.id == tapped.id, orElse: () => tapped);
          final st = room.status;
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
                  _Fact('النوع', room.typeName),
                  _Fact('السعة', '${room.capacity} أشخاص'),
                  _Fact('الطابق', floorName),
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
              else if (!canSetStatus)
                Text(
                  'لا تملك صلاحية تغيير حالة الغرفة.',
                  style: AppText.body(13, color: AppColors.inkMuted),
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
                          onTap: () => _changeStatus(room, o),
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

/// Centered text (and an optional button) for loading errors / empty data.
class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.body(14.5, color: AppColors.inkMuted),
            ),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
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
