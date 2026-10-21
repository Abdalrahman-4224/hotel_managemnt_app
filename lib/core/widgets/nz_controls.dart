import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class NzSegment<T> {
  const NzSegment(this.value, this.label, {this.count});

  final T value;
  final String label;

  /// Optional small number shown after the label.
  final String? count;
}

/// Segmented control on an inert track; the selected segment is a white
/// raised pill.
class NzSegmented<T> extends StatelessWidget {
  const NzSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 44,
    this.fontSize = 14.5,
    this.countAsBadge = false,
  });

  /// Shows each segment's count in a small rounded badge.
  final bool countAsBadge;

  final List<NzSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inert,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(segments[i])),
          ],
        ],
      ),
    );
  }

  Widget _badgeLabel(NzSegment<T> s, bool on) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          s.label,
          style: AppText.body(
            fontSize,
            weight: on ? FontWeight.w600 : FontWeight.w500,
            color: on ? AppColors.ink : AppColors.inkMuted,
            height: 1,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          constraints: const BoxConstraints(minWidth: 20),
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: on ? AppColors.goldTint : const Color(0x141C1B19),
            borderRadius: BorderRadius.circular(99),
          ),
          alignment: Alignment.center,
          child: Text(
            s.count!,
            style: AppText.num(12, color: AppColors.goldDarkest, height: 1),
          ),
        ),
      ],
    );
  }

  Widget _segment(NzSegment<T> s) {
    final on = s.value == selected;
    return Semantics(
      selected: on,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(s.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          decoration: BoxDecoration(
            color: on ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: on ? AppShadows.segment : null,
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: countAsBadge && s.count != null
                ? _badgeLabel(s, on)
                : Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: s.label),
                        if (s.count != null)
                          TextSpan(
                            text: ' ${s.count}',
                            style: AppText.num(
                              11.5,
                              weight: FontWeight.w500,
                              color: (on ? AppColors.ink : AppColors.inkMuted)
                                  .withValues(alpha: .65),
                            ),
                          ),
                      ],
                    ),
                    style: AppText.body(
                      fontSize,
                      weight: on ? FontWeight.w600 : FontWeight.w500,
                      color: on ? AppColors.ink : AppColors.inkMuted,
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Filter chip / option pill: gold-tinted with a deep gold border when on.
class NzChoicePill extends StatelessWidget {
  const NzChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.height = 40,
    this.radius = 99,
    this.fontSize = 13.5,
    this.horizontalPadding = 14,
    this.offColor = AppColors.ink3,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? count;
  final double height;
  final double radius;
  final double fontSize;
  final double horizontalPadding;
  final Color offColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.goldDarkest : offColor;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(minHeight: height),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: selected ? AppColors.goldTint : AppColors.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? AppColors.goldDeep : AppColors.lineStrong,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: label),
                    if (count != null)
                      TextSpan(
                        text: ' $count',
                        style: AppText.num(
                          12,
                          weight: FontWeight.w500,
                          color: fg.withValues(alpha: .7),
                        ),
                      ),
                  ],
                ),
                style: AppText.body(
                  fontSize,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of pills that bleeds to the screen edges.
class NzPillScroller extends StatelessWidget {
  const NzPillScroller({super.key, required this.children, this.gap = 8});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// 48×28 gold switch. In RTL the knob sits at the start when off.
class NzSwitch extends StatelessWidget {
  const NzSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.gold : AppColors.switchOff,
            borderRadius: BorderRadius.circular(99),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            alignment: value
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x401C1B19),
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Radio indicator: thick gold ring when selected.
class NzRadioDot extends StatelessWidget {
  const NzRadioDot({
    super.key,
    required this.selected,
    this.size = 20,
    this.color = AppColors.gold,
  });

  final bool selected;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : AppColors.lineHeavy,
          width: selected ? 6 : 1.5,
        ),
      ),
    );
  }
}

/// Rounded selectable option card (radio row) used in sheets.
class NzOptionTile extends StatelessWidget {
  const NzOptionTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.minHeight = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.radius = 16,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double minHeight;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? AppColors.goldTint : AppColors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: selected ? AppColors.gold : AppColors.lineStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Full-width single-choice row: label, optional count, radio at the end.
class NzRadioRow extends StatelessWidget {
  const NzRadioRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.goldTint : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.goldDeep : AppColors.lineStrong,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppText.body(
                    15,
                    weight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.goldDarkest : AppColors.ink,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: AppText.num(
                    13,
                    weight: FontWeight.w500,
                    color: AppColors.inkFaint,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              NzRadioDot(selected: selected, color: AppColors.goldDeep),
            ],
          ),
        ),
      ),
    );
  }
}
