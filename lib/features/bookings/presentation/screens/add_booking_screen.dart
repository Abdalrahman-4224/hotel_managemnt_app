import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../rooms/domain/entities/room.dart';
import '../controllers/add_booking_controller.dart';
import '../widgets/booking_details_sheet.dart';

/// Step 1: choose the room(s). Step 2 opens as a tall sheet.
class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _c = AddBookingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return ListenableBuilder(
      listenable: _c,
      builder: (context, _) => Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                NzPageHeader(
                  showBack: true,
                  subtitle: 'الخطوة 1 من 2 · اختيار الغرف',
                  title: 'إضافة حجز',
                  bottomGap: 14,
                  bottom: NzSegmented<bool>(
                    selected: _c.isGroup,
                    onChanged: _c.setGroup,
                    segments: const [
                      NzSegment(false, 'حجز فرد'),
                      NzSegment(true, 'حجز حملة'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(top: 14, bottom: 120 + bottom),
                    children: [
                      NzPillScroller(
                        children: [
                          for (final (i, f) in _c.floors.indexed)
                            NzChoicePill(
                              label: f.name,
                              count: '${f.rooms.where((r) => r.isFree).length}',
                              selected: _c.floor == i,
                              onTap: () => _c.setFloor(i),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _c.isGroup
                                  ? 'اختر غرف الحملة من الغرف المتاحة — يمكنك التنقل بين الطوابق.'
                                  : 'اختر غرفة واحدة متاحة.',
                              style: AppText.body(
                                13.5,
                                color: AppColors.inkMuted,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 14),
                            NzGrid(
                              children: [
                                for (final r in _c.floors[_c.floor].rooms)
                                  _PickTile(
                                    room: r,
                                    selected: _c.selected.contains(r.number),
                                    onTap: () => _c.toggleRoom(r),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 24 + bottom,
              child: _SelectionBar(
                controller: _c,
                onNext: () => showBookingDetails(context, _c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickTile extends StatelessWidget {
  const _PickTile({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final Room room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final free = room.isFree;
    final fg = selected
        ? AppColors.goldDarkest
        : free
        ? AppColors.ink
        : AppColors.inkFaint;
    return Semantics(
      button: true,
      enabled: free,
      selected: selected,
      label: 'غرفة ${room.number}${free ? '' : ' — ${room.status.label}'}',
      child: GestureDetector(
        onTap: free ? onTap : null,
        child: Opacity(
          opacity: free || selected ? 1 : .55,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.goldTint
                  : free
                  ? AppColors.card
                  : AppColors.inert,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? AppColors.goldDeep
                    : free
                    ? AppColors.line
                    : const Color(0x0F1C1B19),
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? const [BoxShadow(color: Color(0x21B68235), spreadRadius: 4)]
                  : free
                  ? AppShadows.card
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(room.number, style: AppText.num(17, color: fg, height: 1)),
                const SizedBox(height: 6),
                Text(
                  free ? room.type : room.status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    11.5,
                    color: selected
                        ? AppColors.goldDarkest
                        : AppColors.inkMuted,
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

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.controller, required this.onNext});

  final AddBookingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final n = controller.selected.length;
    final enabled = n > 0;
    return Container(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D1C1B19),
                offset: Offset(0, 10),
                blurRadius: 26,
                spreadRadius: -12,
              ),
              BoxShadow(
                color: Color(0x801C1B19),
                offset: Offset(0, 48),
                blurRadius: 88,
                spreadRadius: -40,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.kindLabel,
                      style: AppText.body(12.5, color: AppColors.onInkMuted),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'المحدّد '),
                          TextSpan(
                            text: '$n',
                            style: AppText.num(16, color: AppColors.goldLight),
                          ),
                          TextSpan(text: ' ${n == 1 ? 'غرفة' : 'غرف'}'),
                        ],
                      ),
                      style: AppText.body(
                        15,
                        weight: FontWeight.w500,
                        color: AppColors.onInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: enabled ? onNext : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: enabled ? Colors.white : const Color(0x1FFFFFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'متابعة',
                        style: AppText.body(
                          15,
                          weight: FontWeight.w600,
                          color: enabled
                              ? AppColors.ink
                              : const Color(0x66F8F5F1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        LucideIcons.chevronLeft,
                        size: 17,
                        color: enabled
                            ? AppColors.ink
                            : const Color(0x66F8F5F1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, curve: AppMotion.easeOut)
        .moveY(begin: 14, end: 0, duration: 400.ms, curve: AppMotion.easeOut);
  }
}
