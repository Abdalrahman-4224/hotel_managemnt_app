import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Solid ink button (the design's primary action).
class NzPrimaryButton extends StatelessWidget {
  const NzPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 54,
    this.radius = 16,
    this.background = AppColors.ink,
    this.foreground = AppColors.onInk,
    this.iconColor = AppColors.goldLight,
    this.fontSize = 15.5,
    this.weight = FontWeight.w600,
    this.shadow,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final double radius;
  final Color background;
  final Color foreground;
  final Color iconColor;
  final double fontSize;
  final FontWeight weight;
  final List<BoxShadow>? shadow;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final enabled = !disabled && onPressed != null;
    return Opacity(
      opacity: disabled ? .45 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: shadow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: enabled ? onPressed : null,
            child: _ButtonContent(
              icon: icon,
              iconSize: 18,
              iconColor: iconColor,
              gap: 9,
              padding: 16,
              label: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.body(
                  fontSize,
                  weight: weight,
                  color: foreground,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White button with a hairline border (secondary action).
class NzOutlineButton extends StatelessWidget {
  const NzOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconColor = AppColors.goldDeep,
    this.height = 52,
    this.radius = 16,
    this.background = AppColors.card,
    this.foreground = AppColors.ink,
    this.borderColor = AppColors.lineStrong,
    this.fontSize = 15,
    this.weight = FontWeight.w500,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color iconColor;
  final double height;
  final double radius;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final double fontSize;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: _ButtonContent(
            icon: icon,
            iconSize: 16,
            iconColor: iconColor,
            gap: 6,
            padding: 12,
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                fontSize,
                weight: weight,
                color: foreground,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Square icon button (44×44, radius 14) used in page headers.
class NzIconButton extends StatelessWidget {
  const NzIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
    this.radius = 14,
    this.iconSize = 19,
    this.iconColor = AppColors.ink3,
    this.background = AppColors.card,
    this.borderColor = AppColors.lineStrong,
    this.borderWidth = 1,
    this.showDot = false,
    this.badge,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double radius;
  final double iconSize;
  final Color iconColor;
  final Color background;
  final Color borderColor;
  final double borderWidth;
  final bool showDot;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
    if (showDot || badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (showDot)
            Positioned(
              top: 9,
              left: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          if (badge != null)
            Positioned(
              top: -5,
              left: -5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: AppColors.paper, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: AppText.num(11.5, color: Colors.white, height: 1),
                ),
              ),
            ),
        ],
      );
    }
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Underlined inline text action (e.g. "تغيير الرقم").
class NzLinkButton extends StatelessWidget {
  const NzLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.goldDeep,
    this.fontSize = 14,
    this.weight = FontWeight.w500,
    this.underline = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double fontSize;
  final FontWeight weight;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: AppText.body(
                fontSize,
                weight: weight,
                color: color,
                height: 1,
                decoration: underline ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon + label, centred. In a bounded width the label ellipsizes; in an
/// unbounded row (e.g. header actions) the button sizes to its content.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.gap,
    required this.padding,
  });

  final Widget label;
  final IconData? icon;
  final double iconSize;
  final Color iconColor;
  final double gap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final bounded = c.hasBoundedWidth;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: iconColor),
                SizedBox(width: gap),
              ],
              bounded ? Flexible(child: label) : label,
            ],
          ),
        );
      },
    );
  }
}
