import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

enum NzTagTone { gold, dark, neutral, solidGold, outline }

/// Small rounded status tag (e.g. "وصول", "تأخر").
class NzTag extends StatelessWidget {
  const NzTag(
    this.label, {
    super.key,
    this.tone = NzTagTone.neutral,
    this.height = 26,
    this.fontSize = 12.5,
    this.icon,
  });

  final String label;
  final NzTagTone tone;
  final double height;
  final double fontSize;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border, weight) = switch (tone) {
      NzTagTone.gold => (
        AppColors.goldTint,
        AppColors.goldDarkest,
        AppColors.goldBorder,
        FontWeight.w600,
      ),
      NzTagTone.dark => (AppColors.ink, AppColors.onInk, null, FontWeight.w600),
      NzTagTone.solidGold => (
        AppColors.gold,
        AppColors.ink,
        null,
        FontWeight.w600,
      ),
      NzTagTone.outline => (
        AppColors.card,
        AppColors.ink3,
        AppColors.lineStrong,
        FontWeight.w500,
      ),
      NzTagTone.neutral => (
        AppColors.inert,
        AppColors.ink3,
        null,
        FontWeight.w500,
      ),
    };
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height < 26 ? 8 : 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: border == null ? null : Border.all(color: border),
      ),
      // Center(widthFactor: 1) keeps the pill hugging its label even when
      // the parent offers more width (Wrap, fixed table cells).
      child: Center(
        widthFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 1, color: fg),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppText.body(
                fontSize,
                weight: weight,
                color: fg,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin rounded progress bar.
class NzProgressBar extends StatelessWidget {
  const NzProgressBar({
    super.key,
    required this.value,
    this.height = 5,
    this.track = AppColors.inert,
    this.fill = AppColors.gold,
  });

  final double value;
  final double height;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: ColoredBox(color: track)),
            FractionallySizedBox(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: value.clamp(0, 1),
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gold-tinted circular initial avatar.
class NzInitialAvatar extends StatelessWidget {
  const NzInitialAvatar(
    this.initial, {
    super.key,
    this.size = 38,
    this.fontSize = 14,
    this.serif = false,
    this.dark = false,
  });

  final String initial;
  final double size;
  final double fontSize;
  final bool serif;

  /// Ink background with light gold letter.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? AppColors.goldLight : AppColors.goldDarkest;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppColors.ink : AppColors.goldTint,
        shape: BoxShape.circle,
        border: dark ? null : Border.all(color: AppColors.goldBorderSoft),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: serif
            ? AppText.display(fontSize, color: color, height: 1)
            : AppText.body(
                fontSize,
                weight: FontWeight.w600,
                color: color,
                height: 1,
              ),
      ),
    );
  }
}

enum NzIconTileTone { tint, inert, solidGold, ink }

/// Rounded square holding an icon (section tiles, list leading icons).
class NzIconTile extends StatelessWidget {
  const NzIconTile(
    this.icon, {
    super.key,
    this.tone = NzIconTileTone.tint,
    this.size = 42,
    this.radius = 14,
    this.iconSize = 20,
  });

  final IconData icon;
  final NzIconTileTone tone;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (tone) {
      NzIconTileTone.tint => (
        AppColors.goldTint,
        AppColors.goldDeep,
        AppColors.goldBorderSoft,
      ),
      NzIconTileTone.inert => (AppColors.inert, AppColors.ink3, null),
      NzIconTileTone.solidGold => (AppColors.gold, AppColors.ink, null),
      NzIconTileTone.ink => (AppColors.ink, AppColors.goldLight, null),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: border == null ? null : Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: fg),
    );
  }
}

/// The square "نُ" brand mark.
class NzBrandMark extends StatelessWidget {
  const NzBrandMark({super.key, this.size = 42, this.radius = 14});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final big = size > 50;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: big ? AppShadows.ink : null,
        border: big ? Border.all(color: const Color(0x38E3B06A)) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        'نُ',
        style: AppText.display(
          size * .44,
          color: AppColors.goldLight,
          height: 1,
        ),
      ),
    );
  }
}

/// "123 دولار" – a number in Lora followed by a small unit label.
class NzAmount extends StatelessWidget {
  const NzAmount(
    this.value,
    this.unit, {
    super.key,
    this.size = 20,
    this.color = AppColors.ink,
    this.unitColor = AppColors.inkMuted,
    this.unitSize = 11.5,
  });

  final String value;
  final String unit;
  final double size;
  final Color color;
  final Color unitColor;
  final double unitSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: AppText.num(size, color: color, height: 1),
          ),
          TextSpan(
            text: ' $unit',
            style: AppText.body(unitSize, color: unitColor),
          ),
        ],
      ),
    );
  }
}
