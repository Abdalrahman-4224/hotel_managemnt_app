import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/room.dart';

/// Small square legend swatch for a room status.
class RoomStatusDot extends StatelessWidget {
  const RoomStatusDot(this.status, {super.key});

  final RoomStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, border) = switch (status) {
      RoomStatus.free => (Colors.white, const Color(0x401C1B19)),
      RoomStatus.busy => (AppColors.ink, null),
      RoomStatus.held => (AppColors.goldTint, AppColors.gold),
      RoomStatus.maintenance => (const Color(0xFFCFCBC6), null),
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: border == null ? null : Border.all(color: border),
      ),
    );
  }
}

/// Room tile in the 4-column floor grid.
class RoomTile extends StatelessWidget {
  const RoomTile({
    super.key,
    required this.room,
    required this.status,
    required this.onTap,
  });

  final Room room;
  final RoomStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, sub, border, shadow) = switch (status) {
      RoomStatus.busy => (
        AppColors.ink,
        AppColors.amber,
        AppColors.onInkMuted,
        null,
        null,
      ),
      RoomStatus.held => (
        AppColors.goldTint,
        AppColors.goldDarkest,
        AppColors.goldDarkest,
        AppColors.gold,
        null,
      ),
      RoomStatus.maintenance => (
        AppColors.inert,
        AppColors.ink3,
        AppColors.ink3,
        const Color(0x141C1B19),
        null,
      ),
      RoomStatus.free => (
        AppColors.card,
        AppColors.ink,
        AppColors.inkMuted,
        AppColors.line,
        AppShadows.card,
      ),
    };
    return Semantics(
      button: true,
      label: 'غرفة ${room.number} — ${status.label}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: border == null ? null : Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(room.number, style: AppText.num(17, color: fg, height: 1)),
              const SizedBox(height: 6),
              Text(
                status == RoomStatus.free ? room.type : status.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(11.5, color: sub),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status pill used in the room sheet header.
class RoomStatusTag extends StatelessWidget {
  const RoomStatusTag(this.status, {super.key});

  final RoomStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (status) {
      RoomStatus.busy => (AppColors.ink, AppColors.onInk, null),
      RoomStatus.held => (
        AppColors.goldTint,
        AppColors.goldDarkest,
        const Color(0x66B68235),
      ),
      RoomStatus.maintenance => (AppColors.inert, AppColors.ink3, null),
      RoomStatus.free => (AppColors.card, AppColors.ink, AppColors.lineStrong),
    };
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: border == null ? null : Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Text(
        status.label,
        style: AppText.body(13, weight: FontWeight.w600, color: fg),
      ),
    );
  }
}
